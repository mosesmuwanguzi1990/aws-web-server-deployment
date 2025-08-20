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

resource "aws_lb" "front_end" {
subnet_mapping {
    subnet_id =  aws_subnet.public-subnet-a.id
}
}

resource "aws_lb_target_group" "front_end" {
  # ...
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.WebALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:711387106973:certificate/0303d743-b2bb-4d09-baed-05e059839ff5"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}