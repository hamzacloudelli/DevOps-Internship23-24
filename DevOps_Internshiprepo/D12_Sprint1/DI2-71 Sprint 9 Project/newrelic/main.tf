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
    Name = "hamzaci-vpc"
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
  instance_id = aws_instance.example_instance.id
  allocation_id = aws_eip.example.id
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
    Name = "example-igw"
  }
}

resource "aws_subnet" "example_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"  # Adjust the availability zone as needed
  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic to the internet gateway
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "example-route-table"
  }
}

resource "aws_route_table_association" "example_route_table_association" {
  subnet_id = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_instance" "example_instance" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.example_subnet.id
  user_data = <<-EOF
    #!/bin/bash
    curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=${var.new_relic_api_key} NEW_RELIC_ACCOUNT_ID=${var.new_relic_account_id} /usr/local/bin/newrelic install -y
    EOF

  tags = {
    Name = "hamzaci"
  }
}
