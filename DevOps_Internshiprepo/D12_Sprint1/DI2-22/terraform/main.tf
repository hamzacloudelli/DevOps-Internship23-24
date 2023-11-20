resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hamzavpcproj"
  }
}

# elastic ip association
resource "aws_eip_association" "hamza_eip_assoc" {
  instance_id = aws_instance.web.id
}

# elastic ip association
resource "aws_eip_association" "hamza_eip_assoc2" {
  instance_id = aws_instance.web2.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  domain = "vpc"
}


resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  depends_on = [ aws_vpc.vpc ]

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id           = aws_vpc.vpc.id
  cidr_block       = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "another-private-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "hamzaigw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_route_table_association2" {
  subnet_id = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_security_group" "webssh" {
  name        = "webssh"
  description = "Allow SSH from local IP only"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["192.168.1.0/24"]
  }

  ingress {
    description = "EFS mount target"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-ssh"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.webssh.id]

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
    Name = "hamzaproj3"
  }
}


resource "aws_instance" "web2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet2.id
  vpc_security_group_ids = [aws_security_group.webssh.id]
  
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
    Name = "hamzaproj31"
  }
}




resource "aws_ebs_volume" "volume" {

// Here , We need to give same AZ as the INstance Have.
    availability_zone = aws_instance.web.availability_zone

// Size IN GiB
    size = 1

    tags = {

        Name = "terraformTesting"
    }    
}

#attaching the volume to ec2 instance 

resource "aws_volume_attachment" "ebsAttach" {

    device_name = "/dev/sdh"
    volume_id = aws_ebs_volume.volume.id
    instance_id = aws_instance.web.id

}

resource "aws_efs_file_system" "efs_fs" {
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.efs_fs.id
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.webssh.id]
  depends_on = [aws_efs_file_system.efs_fs]
}