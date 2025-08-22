resource "aws_security_group" "WebSG" {
  name        = "allow_vm_access"
  description = "Allow VM Access"
  vpc_id      = aws_vpc.moses-vpc.id

  tags = {
    Name = "allow_vm_access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = aws_vpc.moses-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = aws_vpc.moses-vpc.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.WebSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}




resource "aws_security_group" "ALBSG" {
  name        = "allow_alb_access"
  description = "Allow application load balancer Access"
  vpc_id      = aws_vpc.moses-vpc.id

  tags = {
    Name = "allow_alb_access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_applb" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_applb" {
  security_group_id = aws_security_group.ALBSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

