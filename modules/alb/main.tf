locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. The Application Load Balancer
resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  internal           = false # False means it is internet-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = var.logs_bucket_id
    prefix  = "alb" 
    enabled = true
  }

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

# 2. The Target Group (Receives traffic from ALB and sends to EC2)
resource "aws_lb_target_group" "app_tg" {
  name     = "${local.name_prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name = "${local.name_prefix}-app-tg"
  }
}

# 3. The Listener (Listens on port 80 and forwards to the Target Group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}