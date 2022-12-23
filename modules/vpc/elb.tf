resource "aws_lb" "frontend_lb" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_lb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "frontend_tg" {
  count = length(var.target_group_instance_ids)
  name = "frontend-tg-${count.index}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_target_group_attachment" "frontend_tg_attachment" {
  count = length(aws_lb_target_group.frontend_tg)
  target_group_arn = aws_lb_target_group.frontend_tg[count.index].arn
  target_id        = var.target_group_instance_ids[count.index]
  port             = 80
}

resource "aws_lb_listener" "frontend_lb_http_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg[0].arn
  }
}

resource "aws_lb_listener_rule" "frontend_lb_http_listener_rule" {
  count = length(aws_lb_target_group.frontend_tg)
  listener_arn = aws_lb_listener.frontend_lb_http_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg[count.index].arn
  }

  condition {
    path_pattern {
      values = ["/wordpress${count.index}*"]
    }
  }
}