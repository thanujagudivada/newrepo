resource "aws_ecs_cluster" "main" {
  name = "medusa-cluster"
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "medusa-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # Add cpu and memory at the task level for Fargate
  cpu     = "256"  # CPU in units (e.g., 256 units = 0.25 vCPU)
  memory  = "512"  # Memory in MiB (e.g., 512MB)

  container_definitions = jsonencode([{
    name      = "medusa-container"
    image     = "medusajs/medusa"  # Use the Medusa Docker image or your custom image
    cpu       = 256                # Optional: you can define cpu at the container level (defaults to task-level if not defined)
    memory    = 512                # Optional: you can define memory at the container level (defaults to task-level if not defined)
    essential = true
  }])
}

resource "aws_ecs_service" "medusa_service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id]  # Make sure you replace with actual subnet ID
    security_groups = [aws_security_group.ecs_security_group.id]  # Make sure you replace with actual security group ID
  }
}
