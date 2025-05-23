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

# ECS Cluster
resource "aws_ecs_cluster" "todo_cluster" {
  name = "todo-cluster"
}

# ECR Repository
resource "aws_ecr_repository" "todo_repo" {
  name = "my-todo-app"
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

# ECS Service (without load balancer)
resource "aws_ecs_service" "todo_service" {
  name            = "todo-service"
  cluster         = aws_ecs_cluster.todo_cluster.id
  task_definition = aws_ecs_task_definition.todo_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-123456"]
  }
}
resource "aws_ecs_task_definition" "todo_task" {
  family                   = "todo-task"
  network_mode             = "bridge"  # Changed from 'awsvpc'
  requires_compatibilities = ["FARGATE"]  # Remove if not using Fargate
}