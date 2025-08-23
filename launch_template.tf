### Launch Template for EC2 Instances and create an Auto Scaling Group which will const of 2 instances
resource "aws_launch_template" "my_web_template" {
  disable_api_termination = false
  instance_type           = "t2.micro"
  image_id                = "ami-0360c520857e3138f"
  key_name                = "moses2025"
  vpc_security_group_ids  = [aws_security_group.ALBSG.id]
  tags = merge(
    local.default_tags,
    {
      Name = "WebServerInstance"
    },
  ) 
  user_data               = filebase64("user_data.sh")
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 10
      volume_type           = "gp3"
      delete_on_termination = false
    }
  }
}



resource "aws_autoscaling_group" "web_autoscaling_group" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id]

  launch_template {
    # id      = aws_launch_template.my_web_template.id
    name    = aws_launch_template.my_web_template.name
    version = "$Latest"
  }
}