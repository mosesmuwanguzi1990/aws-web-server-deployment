
### Create Security Groups for EC2 Instances and Application Load Balancer (ALB) which will allow traffic on port 443 from ALB to EC2 instances and allow SSH access from VPC CIDR to EC2 instances

## Create a Security Group for EC2 Instances
resource "aws_security_group" "WebSG" {
  name        = "allow_vm_access"
  description = "Allow VM Access"
  vpc_id      = aws_vpc.moses-vpc.id

  tags = merge(
    local.default_tags,
    {
      Name = "WebSG"
    }

  )  
  
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = aws_vpc.moses-vpc.cidr_block
  from_port         = var.secure_port
  ip_protocol       = "tcp"
  to_port           = var.secure_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = aws_vpc.moses-vpc.cidr_block
  from_port         = var.ssh_port
  ip_protocol       = "tcp"
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = var.cdir_anywhere
  ip_protocol       = "-1"
}



## Create a Security Group for Application Load Balancer (ALB)
resource "aws_security_group" "ALBSG" {
  name        = "allow_alb_access"
  description = "Allow application load balancer Access"
  vpc_id      = aws_vpc.moses-vpc.id

  tags = merge (local.default_tags,
  {
    Name = "ALBSG"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_applb" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = var.cdir_anywhere
  from_port         = var.secure_port
  ip_protocol       = "tcp"
  to_port           = var.secure_port
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_applb" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = var.cdir_anywhere
  ip_protocol       = "-1"
}

