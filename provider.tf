# Terraform version and providers needed for the project
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

  # Configuring the backend to store Terraform state in my S3 bucket
  backend "s3" {
    bucket = "s3-backend-tfstate-tanishka"
    key    = "Terraform-eks/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# Cluster ID for the EKS cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

# Authentication data for the EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Configuring the Kubernetes provider
provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
}


provider "aws" {
  region = "ap-northeast-1"
}

# To use as a suffix for resources needing unique names
resource "random_string" "suffix" {
  length  = 5
  special = false
}
