resource "aws_launch_template" "my_next_template" {
   disable_api_termination = false
   instance_type = "t2.micro"
   image_id  = "ami-00a790ef5f7f97fbb" 
   key_name = "moses2025"
  vpc_security_group_ids = [aws_security_group.WebSG.id]

  placement {
    availability_zone = "us-east-1a"
  }
}

resource "aws_autoscaling_group" "bar" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 2
  max_size           = 2
  min_size           = 2

  launch_template {
    id      = aws_launch_template.my_next_template.id
    version = "$Latest"
  }
}