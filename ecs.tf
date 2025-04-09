resource "aws_ecs_cluster" "ecs_cluster" {
  name = "pharmacy-cluster"
}

resource "aws_ecs_task_definition" "pharmacy_task" {
  family                   = "pharmacy-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "pharmacy-container"
      image     = "${aws_ecr_repository.pharmacy_ecr.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"

        }
      ]
    }
  ])
}

resource "aws_ecs_service" "pharmacy_service" {
  name            = "pharmacy-service"
  cluster        = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.pharmacy_task.arn
  desired_count  = 2
  launch_type    = "FARGATE"

  deployment_controller {
  type = "CODE_DEPLOY"
  }


  depends_on = [aws_lb.ecs_alb] # Ensure ALB is created before ECS service

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue_tg.arn
    container_name   = "pharmacy-container"
    container_port   = 80
  }
}
