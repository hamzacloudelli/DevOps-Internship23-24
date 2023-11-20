resource "aws_lb" "alb" {
  name      = "hamza-alb"
  subnets   = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
  security_groups = [aws_security_group.webssh.id]
  internal = false
  load_balancer_type = "application"
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port            = 80
  protocol         = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.web_tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "hamza-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id

  health_check {
    path = "/"
    port = "80"
    interval = 30
    timeout = 5
  }
}