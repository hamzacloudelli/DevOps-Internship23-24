# Create elastic beanstalk application
 
resource "aws_elastic_beanstalk_application" "elasticapp" {
  name = var.elasticapp
}
 
resource "aws_iam_role" "aws-elasticbeanstalk-ec2-role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "elasticbeanstalk_instance_profile145" {
  name = "elasticbeanstalk-instance-profile145"
  role = aws_iam_role.aws-elasticbeanstalk-ec2-role.name
}
# Attach AdministratorAccess policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_administrator_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.aws-elasticbeanstalk-ec2-role.name
}


resource "aws_elastic_beanstalk_environment" "hamzatest13g53" {
  name                = "hamzatest13g53"
  application         = aws_elastic_beanstalk_application.elasticapp.name
  solution_stack_name = var.solution_stack_name
  tier                = var.tier
  wait_for_ready_timeout = "20m"
  setting {

    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration" 
    name      = "IamInstanceProfile"
    value     =  aws_iam_instance_profile.elasticbeanstalk_instance_profile145.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     =  "True"
  }
 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.public_subnets)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.medium"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 2
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
 
}
