terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


resource "aws_ecr_repository" "flask_app_repo" {
  name                 = "cloudinternhamza"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
   
}


locals {

  aws_account = "979490057625"   # AWS account
  aws_region  = "us-east-1"      # AWS region
 ///////////////////////////////////////////////////////////////////////////////////////////// 
  ecr_reg   = "${local.aws_account}.dkr.ecr.${local.aws_region}.amazonaws.com" # ECR docker registry URI
  ecr_repo  = "cloudinternhamza"                                                           # ECR repo name
  image_tag = "latest"                                                         # image tag

  dkr_img_src_path = "${path.module}/flaskapp"
  dkr_img_src_sha256 = sha256(join("", [for f in fileset(".", "${local.dkr_img_src_path}/**") : file(f)]))

  dkr_build_cmd = <<-EOT
        docker build -t ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag} \
            -f ${local.dkr_img_src_path}/Dockerfile .

        aws ecr get-login-password --region ${local.aws_region} | \
            docker login --username AWS --password-stdin ${local.ecr_reg}

        docker push ${local.ecr_reg}/${local.ecr_repo}:${local.image_tag}
    EOT
}

variable "force_image_rebuild" {
  type    = bool
  default = false
}

# local-exec for build and push of docker image
resource "null_resource" "build_push_dkr_img" {
  triggers = {
    detect_docker_source_changes = var.force_image_rebuild == true ? timestamp() : local.dkr_img_src_sha256
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }
}

output "trigged_by" {
  value = null_resource.build_push_dkr_img.triggers
}







