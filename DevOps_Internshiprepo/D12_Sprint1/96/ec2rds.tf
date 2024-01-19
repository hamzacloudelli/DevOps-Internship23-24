
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
# EC2
resource "aws_instance" "wordpress" {
  count = 2  # Create two instances
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "hamzaecsec2"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker
    sudo service docker start
    sudo usermod -aG docker ec2-user
    sudo docker run -d -p 80:80 --name wordpress_instance wordpress
    EOF

  subnet_id = element(
    [aws_subnet.public1.id, aws_subnet.public2.id],
    count.index  # Assign each instance to a different subnet
  )
    tags = {
    Name = "hamzaciWordPress-${count.index + 1}"  # Example: WordPress-1, WordPress-2
    Owner = "Your Name"  # Replace with your name or team
    Environment = "Production"  # Example, adjust as needed
  }
}


#rds subnet
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
#RDS INSTANCE
resource "aws_db_instance" "rds_instance" {
  engine                    = "mysql"
  engine_version            = "5.7"
  skip_final_snapshot       = true
  final_snapshot_identifier = "my-final-snapshot"
  instance_class            = "db.t2.micro"
  allocated_storage         = 20
  identifier                = "my-rds-instance"
  db_name                   = "wordpress_db"
  username                  = "hamzaci"
  password                  = "hamza!123"
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.rds_security_group.id]

  tags = {
    Name = "RDS Instance"
  }
}
# RDS security group
resource "aws_security_group" "rds_security_group" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.100.0.0/16"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}



/*
resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name      = "hamzaecsec2"
  subnet_id                  = aws_subnet.public1.id
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              sudo docker run -d -p 80:80 --name wordpress_instance wordpress
              EOF
 
  tags = {
    Name = "hamzacip1Instance"
  }
}


#EC2
resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name      = "hamzaecsec2"
  subnet_id                  = aws_subnet.public2.id
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker
              sudo service docker start
              sudo usermod -aG docker ec2-user
              sudo docker run -d -p 80:80 --name wordpress_instance wordpress
              EOF

  tags = {
    Name = "hamzacip2Instance"
  }

}
*/
