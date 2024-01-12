terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_vpc" "custom" {
  
  # IP Range for the VPC
  cidr_block = "192.168.0.0/16"
  
  # Enabling automatic hostname assigning
  enable_dns_hostnames = true
  tags = {
    Name = "hamzaci"
  }
}

resource "aws_subnet" "subnet1" {
  depends_on = [
    aws_vpc.custom
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.custom.id
  
  # IP Range of this subnet
  cidr_block = "192.168.1.0/24"
  
  # Data Center of this subnet.
  availability_zone = "us-east-1a"
  
  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Creating Public subnet!
resource "aws_subnet" "subnet2" {
  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.custom.id
  
  # IP Range of this subnet
  cidr_block = "192.168.2.0/24"
  
  # Data Center of this subnet.
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "Private Subnet"
  }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}


# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.custom,
    aws_internet_gateway.Internet_Gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.custom.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.custom,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_route_table.Public-Subnet-RT
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.subnet1.id

#  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.RT-IG-Association
  ]
  vpc = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  
  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.subnet1.id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]

  vpc_id = aws_vpc.custom.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

#  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id      = aws_subnet.subnet2.id

# Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_security_group" "public_instance_sg" {
  vpc_id = aws_vpc.custom.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_instance_sg" {
  vpc_id = aws_vpc.custom.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }
  
  ///////////////updated //////////////////
  ////////////////code////////////////

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"] 

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # Replace with desired AMI name pattern
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
 


resource "aws_instance" "public_instance" {
  depends_on = [
    aws_security_group.public_instance_sg
  ]
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "hamzaecsec2"
  subnet_id     = aws_subnet.subnet1.id
  security_groups = [aws_security_group.public_instance_sg.id]

    # Add provisioners to copy the pem key and set permissions
  provisioner "file" {
    source      = "./hamzaecsec2.pem"  # Corrected source path
    destination = "/home/ec2-user/hamzaecsec2.pem"  # Adjusted destination path on the remote instance
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/hamzaecsec2.pem"  # Corrected path on the remote instance
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Replace with the appropriate user
    private_key = file("./hamzaecsec2.pem")  # Corrected path on your local machine
    host        = aws_instance.public_instance.public_ip
  }
 
  tags = {
    Name = "hamzaciPublicInstance"
  }
}

resource "aws_instance" "private_instance" {
   
    depends_on = [
    aws_security_group.private_instance_sg
  ]
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "hamzaecsec2"
  subnet_id     = aws_subnet.subnet2.id
  security_groups = [aws_security_group.private_instance_sg.id]

  tags = {
    Name = "hamzaciPrivateInstance"
  }
}

# Create an Elastic IP (EIP)
resource "aws_eip" "my_eip" {
  vpc = true  # Assign to a VPC
}

# Attach the EIP to the instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.public_instance.id  # Replace with your instance ID
  allocation_id = aws_eip.my_eip.id
}

