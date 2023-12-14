resource "aws_ecr_repository" "hamzaci" {
  name         = "hamzaci"
  force_delete = false

  tags = {
    Name        = "hamzaci"
    Owner       = "hamzaci"
  }
}