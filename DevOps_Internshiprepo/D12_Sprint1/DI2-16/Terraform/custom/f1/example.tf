resource "aws_instance" "week3hamzatask" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  
  tags = {
    Name = "hamza2"
  }
}


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

module "my_ec2_instance" {
  source = "../new"
  ec2_instance_type = var.ec2_instance_type
  ec2_ami_id = data.aws_ami.amazon_linux_2.id
}

