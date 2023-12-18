terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_subnet" "public" {
    count = var.subnet_count.public
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_subnet" "private" {
    count = var.subnet_count.private
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_route_table_association" "public" {
    count = var.subnet_count.public
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {

    vpc_id = aws_vpc.main.id

    tags = {
        Name = "hamzaci"
    }
}

resource "aws_route_table_association" "private" {
    count = var.subnet_count.private
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web" {
    name = "hamzaci"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "hamzaci"
    }
}

resource "aws_security_group" "rds" {
    name = "hamzaci1"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.web.id]
    
    }

    tags = {
        Name = "hamzaci"
    }
}

resource "aws_db_subnet_group" "rds" {
    name = "hamzaci"
    subnet_ids = [for subnet in aws_subnet.private : subnet.id]
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_db_instance" "rds" {
    allocated_storage = 10
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t2.micro"
    username = "hamzaci"
    password = "hamzaci123"
    vpc_security_group_ids = [aws_security_group.rds.id]
    db_subnet_group_name = aws_db_subnet_group.rds.name
    skip_final_snapshot = true
    multi_az = true
}

data "aws_key_pair" "existing_hamzaecsec2" {
  key_name = "hamzaecsec2"
}

resource "aws_instance" "web" {
    count = var.settings.web_app.count
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web.id]
    subnet_id = aws_subnet.public[count.index].id
    associate_public_ip_address = true
    key_name =  data.aws_key_pair.existing_hamzaecsec2.key_name
    tags = {
        Name = "hamzaci"
    }
}

resource "aws_eip" "web" {
    count = var.settings.web_app.count
    instance = aws_instance.web[count.index].id
    vpc = true
    tags = {
        Name = "hamzaci"
    }
}

