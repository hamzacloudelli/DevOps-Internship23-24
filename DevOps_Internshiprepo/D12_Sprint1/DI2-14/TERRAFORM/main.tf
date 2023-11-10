
# configured aws provider with proper credentials
provider "aws" {
  region    = "us-east-1"
}

# iam user and group
resource "aws_iam_group" "hamzaweek2" {
  name = "hamzaweek2"
}

resource "aws_iam_group_policy_attachment" "administrator-attach" {
  group = aws_iam_group.hamzaweek2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "admin1" {
  name = "admin1"
}

resource "aws_iam_group_membership" "administrators-users" {
  name = "administrators-users"
  users = [aws_iam_user.admin1.name]
  group = aws_iam_group.hamzaweek2.name
}



# elastic ip association
resource "aws_eip_association" "hamza_eip_assoc" {
  instance_id = aws_instance.week2hamzatask.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  domain = "vpc"
}

########################


# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet1"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "hamzasg" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

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


# launch the ec2 instance and install website
resource "aws_instance" "week2hamzatask" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.hamzasg.id]
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install ec2-instance-connect
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker pull nginx
    sudo docker run -d -p 80:80 nginx
  EOF

  tags = {
    Name = "hamza2"
  }
}

