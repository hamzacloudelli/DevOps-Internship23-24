
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

resource "aws_iam_instance_profile" "ec2"{
  name = "ec2-profile"
  role = aws_iam_role.s3_access_role.name
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
  iam_instance_profile = aws_iam_instance_profile.ec2.name
    # Add provisioners to copy the pem key and set permissions
  provisioner "file" {
    source      = "./hamzaecsec2.pem"  
    destination = "/home/ec2-user/hamzaecsec2.pem"  
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/hamzaecsec2.pem"  # Corrected path on the remote instance
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"  # Replace with the appropriate user
    private_key = file("./hamzaecsec2.pem")  
    host        = aws_instance.public_instance.public_ip
  }
 
  tags = {
    Name = "hamzaciPublicInstance"
  }
}

resource "aws_instance" "private_instance" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "hamzaecsec2"
  subnet_id     = aws_subnet.subnet2.id
  security_groups = [aws_security_group.private_instance_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  
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

