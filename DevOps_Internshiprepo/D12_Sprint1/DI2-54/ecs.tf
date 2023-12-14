resource "aws_ecs_cluster" "hamzaci" {
  name = "hamzaci"
}
resource "aws_ecs_service" "hamzaci" {
    name = "hamzaci"
    cluster = aws_ecs_cluster.hamzaci.arn
    launch_type = "FARGATE"
    deployment_maximum_percent = 200
    deployment_minimum_healthy_percent = 0
    desired_count = 1
    task_definition = aws_ecs_task_definition.hamzaci.family
    deployment_controller {
    type = "CODE_DEPLOY"
    } 
    network_configuration {
      assign_public_ip = true
      security_groups = [aws_security_group.ECS.id]
      subnets = module.vpc.public_subnets
    }
    load_balancer {
        target_group_arn = aws_lb_target_group.hamzaciblue.arn
        container_name   = "hamzaci"
        container_port   = 80
        }
    }

resource "aws_ecs_task_definition" "hamzaci" {
  family                   = "nginxserver"
  requires_compatibilities = ["FARGATE"] # Use Fargate compatibility for running tasks
  network_mode             = "awsvpc"
  memory                   = "512" # Set the memory limit for the task
  cpu                      = "256" # Set the CPU units for the task
  execution_role_arn       = aws_iam_role.hamzaciecr.arn

  # Define container definitions as a JSON-encoded array
  container_definitions = jsonencode([
    {
      name       = "hamzaci",
      image      = "${aws_ecr_repository.hamzaci.repository_url}:latest",
      entryPoint = [],
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
        }
      ],
      cpu         = 120,
      memory      = 250,
      networkMode = "awsvpc"

    }
  ])
}