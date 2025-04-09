resource "aws_codedeploy_app" "ecs_codedeploy_app" {
  name = "pharmacy-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_codedeploy_group" {
  app_name              = aws_codedeploy_app.ecs_codedeploy_app.name
  deployment_group_name = "pharmacy-deployment-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" # Uses a built-in ECS config

  ecs_service {
    cluster_name =  aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.pharmacy_service.name
  
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.blue_listener.arn] # Main listener for blue-green deployment
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.green_listener.arn] # Green deployment listener
      }

      target_group {
        name = aws_lb_target_group.blue_tg.name
      }

      target_group {
        name = aws_lb_target_group.green_tg.name
      }
    }
  }

   deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      #wait_time_in_minutes = 5
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }
}
