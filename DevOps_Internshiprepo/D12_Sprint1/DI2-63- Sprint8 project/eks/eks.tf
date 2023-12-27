terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source = "hashicorp/random"
      version = "3.0.0"
    
  }

  tls = {
    source = "hashicorp/tls"
    version = "4.0.4"
  }

  kubernetes = {
    source = "hashicorp/kubernetes"
    version = "2.10.0"
  }
  
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = "us-west-1"  #change your region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint  
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
 }


resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "hamzaci" 
  }
}

resource "aws_iam_policy_attachment" "eks_cluster_policy" {
  name       = "eks-cluster-policy"
  roles      = [aws_iam_role.eks_cluster.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Get default VPC id
data "aws_vpc" "default" {
  default = true
}

# Get public subnets in VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "hamzacimy-eks-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }
}

resource "aws_iam_role" "example" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name = "hamzaci" 
  }

}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}

# Create managed node group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "managed-nodes"
  node_role_arn   = aws_iam_role.example.arn

  subnet_ids = data.aws_subnets.public.ids
  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }
  instance_types = ["t2.micro"]

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.eks
  ]
}