
// Variables
variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default     = {
    public  = 1,
    private = 2
  }
}

variable "settings" {
  description = "Configuration settings"
  type        = map(any)
  default     = {
    "database" = {
      allocated_storage    = 10
      engine               = "mysql"
      engine_version       = "8.0.27"
      instance_class       = "db.t2.micro"
      db_name              = "tutorial"
      skip_final_snapshot  = true
    },
    "web_app" = {
      count          = 1
      instance_type  = "t2.micro"  // the EC2 instance type for the web app
    }
  }
}

variable "public_subnet_cidr_blocks" {
  description = "Available CIDR blocks for public subnets"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}


variable "private_subnet_cidr_blocks" {

description = "Available CIDR blocks for private subnets"

type = list(string)

default = [

"10.0.101.0/24",

"10.0.102.0/24",

"10.0.103.0/24",

"10.0.104.0/24",

]

}

// This variable contains your IP address This

// is used when setting up the SSH rule on the

// web security group

variable "my_ip" {
default = "192.168.10.6"
description = "Your IP address"
type = string
sensitive = true
}

// This variable contains the database master user

// We will be storing this in a secrets file

variable "db_username" {
default = "hamzaci"
description = "Database master username"
type = string
sensitive = true
}


