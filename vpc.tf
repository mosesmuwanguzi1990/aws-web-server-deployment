resource "aws_vpc" "moses-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "moses-vpc-project"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.moses-vpc.id

  tags = {
    Name = "moses-gateway"
  }
}

resource "aws_internet_gateway_attachment" "moses-gateway-attachment" {
  internet_gateway_id = aws_internet_gateway.IGW.id
  vpc_id              = aws_vpc.moses-vpc.id
    depends_on = [aws_vpc.moses-vpc]
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id            = aws_vpc.moses-vpc.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id            = aws_vpc.moses-vpc.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.moses-vpc.id
  cidr_block        = "10.0.128.0/18"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id            = aws_vpc.moses-vpc.id
  cidr_block        = "10.0.192.0/18"
  availability_zone = "us-east-1b"
}

resource "aws_eip" "nat-eip-1a" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-1a"
  }
}

resource "aws_eip" "nat-eip-1b" {
  domain = "vpc"
  tags = {
    Name = "nat-eip-1b"
  }
}


resource "aws_nat_gateway" "NATGW1" {
  allocation_id = aws_eip.nat-eip-1a.id
  subnet_id     = aws_subnet.public-subnet-a.id
  tags = {
    Name = "NATGW1"
  }
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_nat_gateway" "NATGW2" {
  allocation_id = aws_eip.nat-eip-1b.id
  subnet_id     = aws_subnet.public-subnet-b.id
  tags = {
    Name = " NATGW2"
  }
  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.moses-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_internet_gateway.IGW.id
  }
}

resource "aws_route_table" "private-route-table-a" {
  vpc_id = aws_vpc.moses-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    nat_gateway_id = aws_nat_gateway.NATGW1.id
  }
}

resource "aws_route_table" "private-route-table-b" {
  vpc_id = aws_vpc.moses-vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    nat_gateway_id = aws_nat_gateway.NATGW2.id
  }
}

resource "aws_route_table_association" "public-route-table-association-a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public-route-table-association-b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "private-route-table-association-a" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-route-table-a.id
}
resource "aws_route_table_association" "private-route-table-association-b" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private-route-table-b.id
}

