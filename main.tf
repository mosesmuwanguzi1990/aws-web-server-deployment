resource "aws_lb" "WebALB" {
  name               = "WebALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  depends_on = [ aws_subnet.private-subnet-a, aws_subnet.private-subnet-b ]
  subnets = [ aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id ]
    tags = {
    Environment = "production"
  }
}
resource "aws_lb_target_group" "frontend" {
  name     = "frontend2025"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.moses-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "frontendlistner" {
  load_balancer_arn = aws_lb.WebALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:711387106973:certificate/0303d743-b2bb-4d09-baed-05e059839ff5"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.bar.name
  # Attach the ALB Target Group to the Auto Scaling Group 
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}