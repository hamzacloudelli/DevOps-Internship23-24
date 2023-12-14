data "aws_iam_policy_document" "ecr_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken", # line to allow GetAuthorizationToken
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeServices", # Add ECS permission
    ]
    resources = ["*"]
  }
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}