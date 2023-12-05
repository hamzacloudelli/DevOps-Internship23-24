variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "codecommit_repository_name" {
  type = string
  default = "infra-vpc-repo"
}

variable "s3_bucket_name" {
    type = string
    default = "hamza-infra-vpc-backend"
}

#iam roles
variable "codebuild_role_name" {
    type = string
    default = "hamzaciinfra-vpc-codebuild-role" 
}

variable "codepipeline_role_name" {
    type = string
    default = "hamzaciinfra-vpc-codepipeline-role"
}

variable "codebuild_policy_name" {
    type = string
    default = "hamzaciinfra-vpc-codebuild-policy" 
}

variable "codepipeline_policy_name" {
    type = string
    default = "hamzaciinfra-vpc-codepipeline-policy"
}

variable "codebuild_plan_project_name" {
    type = string
    default = "hamzaciinfra-vpc-codebuild-project-plan" 
}

variable "codebuild_apply_project_name" {
    type = string
    default = "hamzaciinfra-vpc-codebuild-project-apply" 
}

variable "codepipeline_name" {
    type = string
    default = "hamzaciinfra-vpc-codepipeline" 
}

