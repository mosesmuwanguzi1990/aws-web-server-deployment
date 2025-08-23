resource "aws_launch_template" "my_web_template" {
  disable_api_termination = false
  instance_type           = "t2.micro"
  image_id                = "ami-0360c520857e3138f"
  key_name                = "moses2025"
  vpc_security_group_ids  = [aws_security_group.ALBSG.id]
  user_data               = <<-EOF
 #!/bin/bash
# Update package lists and upgrade existing packages
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Apache web server
apt-get install apache2 -y

# Enable necessary Apache modules and sites
a2enmod ssl
a2ensite default-ssl.conf

# IMPORTANT: First, add rules to the firewall
ufw allow 'Apache Full'
ufw allow 'OpenSSH'

# THEN, enable the firewall non-interactively
ufw --force enable

# Restart Apache to apply all changes
systemctl restart apache2
                EOF
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