variable "elasticapp" {
  default = "myapplication"
}
variable "beanstalkappenv" {
  default = "myenvironment"
}
variable "solution_stack_name" {
  default = "64bit Amazon Linux 2018.03 v2.9.11 running PHP 5.4"
}
variable "tier" {
  default = "WebServer"
}
 
variable "vpc_id" {
    default = "abc"
}
variable "public_subnets" {
    default = ["abc", "bcd"]
}
