terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "hamzaci-vpc2"
  }
}


resource "aws_eip" "example" {
  vpc = true  # Allocate the EIP within the VPC

  tags = {
    Name = "hamzaci"  # Optional tag for identification
  }
}
# elastic ip association
resource "aws_eip_association" "hamza_eip_assoc" {
  instance_id = aws_instance.example.id
  allocation_id = aws_eip.example.id
}


# create security group for the ec2 instance
resource "aws_security_group" "hamzasg" {
  name        = "hamzaciec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "hamzasg"
  }
}


# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "hamzaci1example-igw"
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"  # Adjust the availability zone as needed
  map_public_ip_on_launch = true

  tags = {
    Name = "hamzaciexample-subnet"
  }
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic to the internet gateway
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "hamzaciexample-route-table"
  }
}

resource "aws_route_table_association" "example_route_table_association" {
  subnet_id = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_instance" "example" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.hamzasg.id]
  tags = {
    Name = "hamzacicloudwatch"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
      alarm_name                = "hamzacicpu-utilization"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "3"
     alarm_description         = "This metric monitors ec2 cpu utilization"
     insufficient_data_actions = []
dimensions = {
       InstanceId = aws_instance.example.id
     }
     alarm_actions = ["arn:aws:automate:us-east-1:ec2:stop"]
}

