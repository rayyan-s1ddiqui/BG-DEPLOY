resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  
   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pharmacy_tg.arn
  }
}

resource "aws_lb_listener" "blue_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 8090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue_tg.arn
  }
}

resource "aws_lb_listener" "green_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green_tg.arn
  }
}
