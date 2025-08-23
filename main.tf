### Create an Application Load Balancer (ALB) with HTTPS listener and target group which will point to the Auto Scaling Group created.
resource "aws_lb" "WebALB" {
  name               = "WebALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALBSG.id]
  depends_on         = [aws_subnet.private-subnet-a, aws_subnet.private-subnet-b]
  subnets            = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id]
  tags = merge(
    local.default_tags,
    {
      Name = "WebALB"
    }
  ) 
}

## Create a Target Group for the ALB which will point to the Auto Scaling Group created
resource "aws_lb_target_group" "frontend" {
  name     = "frontend2025"
  port     = var.secure_port
  protocol = "HTTPS"
  vpc_id   = aws_vpc.moses-vpc.id
  tags = merge(
    local.default_tags,
    {
      Name = "frontend2025"
    }
  )

## Health Check for the Target Group which will check the health of the instances in the Auto Scaling Group om port 443
  health_check {
    protocol            = "HTTPS"
    port                = var.secure_port
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Create a Listener for the ALB which will listen on port 443 and forward traffic to the Target Group created
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
  tags = local.default_tags
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "example" {
  autoscaling_group_name = aws_autoscaling_group.web_autoscaling_group.name
  # Attach the ALB Target Group to the Auto Scaling Group 
  lb_target_group_arn = aws_lb_target_group.frontend.arn
}