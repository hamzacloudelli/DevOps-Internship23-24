# Create a launch configuration for the instances in the autoscaling group
resource "aws_launch_configuration" "my_launch_config" {
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = "hamzaecsec2"
  security_groups             = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install docker
    sudo service docker start
    sudo usermod -aG docker ec2-user
    sudo docker run -d -p 80:80 --name wordpress_instance wordpress
    EOF
}

# Create an autoscaling group
resource "aws_autoscaling_group" "my_asg" {
  launch_configuration = aws_launch_configuration.my_launch_config.id
  vpc_zone_identifier  = [aws_subnet.public1.id, aws_subnet.public2.id]
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2

  # Target group for the load balancer
  target_group_arns = [aws_lb_target_group.my_target_group.arn]
}



# Create a load balancer
resource "aws_lb" "my_lb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh.id]  # Allow HTTP traffic
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
}

# Create a target group for the load balancer
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

    health_check {
    path    = "/"
    matcher = 200
  }
}

# Attach the load balancer to the target group
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

