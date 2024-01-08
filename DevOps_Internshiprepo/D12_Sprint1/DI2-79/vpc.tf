resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

    tags    = {
    Name  = "cloudinternhamza1"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  lifecycle {
    ignore_changes = all
  }

}

resource "aws_subnet" "subnet2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  lifecycle {
    ignore_changes = all
  }

}

resource "aws_internet_gateway" "internet_gateway" {
 vpc_id = aws_vpc.main.id
 lifecycle {
    ignore_changes = all
  }
 tags = {
   Name = "hamzaciinternet_gatewayh"
 }
}

resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gateway.id
 }
}

resource "aws_route_table_association" "subnet_route" {
 subnet_id      = aws_subnet.subnet.id
 route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
 subnet_id      = aws_subnet.subnet2.id
 route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
 name   = "hamzaciecs-security-grouph"
 vpc_id = aws_vpc.main.id

 ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}