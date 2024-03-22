####### EKS Cluster and Node Group Configuration #######

# Create an AWS EKS Cluster with specific configurations
resource "aws_eks_cluster" "aws-eks-cluster" {
  # Cluster name derived from variable
  name     = var.cluster_name
  
  # Associate the IAM role for EKS
  role_arn = aws_iam_role.aws-eks-cluster.arn

  # VPC Configuration: Specify subnets and access settings for the cluster
  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    # Associate the security group for node communication
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  # Ensure IAM role policies are attached before cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSVPCResourceController,
  ]
}

# Define a node group within the EKS cluster for managing worker nodes
resource "aws_eks_node_group" "aws-eks-cluster" {
  # Reference to the created EKS cluster
  cluster_name    = aws_eks_cluster.aws-eks-cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.aws-eks-cluster2.arn
  # Subnets for the node group
  subnet_ids      = var.aws_public_subnet
  # Instance types for worker nodes
  instance_types  = var.instance_types

  # Configuration for remote access to nodes
  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = var.key_pair
  }

  # Scaling configuration for adjusting the size of the node group dynamically
  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  # Dependency on IAM policies for proper node group operation
  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Security group configuration for EKS node group with basic ingress and egress
resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  # Allow inbound HTTP traffic
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM role for the EKS cluster with trust relationship for eks.amazonaws.com
resource "aws_iam_role" "aws-eks-cluster" {
  name = "eks-cluster-aws-eks-cluster"
   assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  # Policy allows EKS service to assume this role
}

# Attach the AmazonEKSClusterPolicy to the aws_eks_cluster IAM role
resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws-eks-cluster.name
}

# Additional IAM role policy attachments for enabling specific EKS and EC2 functionalities
resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.aws-eks-cluster.name
}

# Define a second IAM role for EKS worker nodes with the necessary trust relationship and policies
resource "aws_iam_role" "aws-eks-cluster2" {
  name = "eks-node-group-aws-eks-cluster"
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
  # Policy allows EC2 service to assume this role for worker nodes
}

# Attach policies to the worker node IAM role for EKS worker node operation, CNI plugin, and ECR accessresource "aws_iam
