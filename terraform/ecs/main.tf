resource "aws_ecs_cluster" "main" {
  name = "localstack-ecs-cluster"
}

variable "ecs_execution_role_arn" {
  default = ""
}
resource "aws_ecs_task_definition" "todo_app" {
  family                   = "todo-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "todo-app"
    image     = "ike20743/todo-app:latest" # Your DockerHub image
    essential = true
    portMappings = [{
      containerPort = 8084
      hostPort      = 8084
    }]
  }])
}

resource "aws_ecs_service" "main" {
  name            = "todo-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.todo_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.subnet_ids
  }
}