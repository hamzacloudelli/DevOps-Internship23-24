output "aws_elastic_beanstalk_app_url" {
  value = "http://${aws_elastic_beanstalk_environment.hamzatest13g53.cname}"
}