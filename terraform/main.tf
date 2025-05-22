terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ecr    = "http://localhost:4566"
    ecs    = "http://localhost:4566"
    iam    = "http://localhost:4566"
    s3     = "http://localhost:4566"
    elbv2  = "http://localhost:4566"
  }
}

# IAM Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Cluster (create new instead of data source)
resource "aws_ecs_cluster" "todo_cluster" {
  name = "todo-cluster"
}

# ECR Repository (create new instead of data source)
resource "aws_ecr_repository" "todo_repo" {
  name = "my-todo-app"
}

# Load Balancer
resource "aws_lb" "todo_alb" {
  name               = "todo-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-123456"]
  security_groups    = ["sg-123456"]
}

resource "aws_lb_target_group" "todo_tg" {
  name     = "todo-tg"
  port     = 8084
  protocol = "HTTP"
  vpc_id   = "vpc-123456"

  health_check {
    path                = "/actuator/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "todo_listener" {
  load_balancer_arn = aws_lb.todo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_tg.arn
  }
}

# Task Definition
resource "aws_ecs_task_definition" "todo_task" {
  family                   = "todo-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "todo-app",
    image     = "${aws_ecr_repository.todo_repo.repository_url}:latest",
    essential = true,
    portMappings = [{
      containerPort = 8084,
      hostPort      = 8084,
      protocol      = "tcp"
    }],
    environment = [
      { name = "SPRING_DATASOURCE_URL", value = "jdbc:postgresql://host.docker.internal:5436/tododb" },
      { name = "SERVER_PORT", value = "8084" }
    ],
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8084/actuator/health || exit 1"],
      interval    = 30,
      timeout     = 5,
      retries     = 3,
      startPeriod = 60
    }
  }])
}

# ECS Service
resource "aws_ecs_service" "todo_service" {
  name            = "todo-service"
  cluster         = aws_ecs_cluster.todo_cluster.id
  task_definition = aws_ecs_task_definition.todo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.todo_tg.arn
    container_name   = "todo-app"
    container_port   = 8084
  }

  network_configuration {
    subnets = ["subnet-123456"]
  }

  depends_on = [aws_lb_listener.todo_listener]
}