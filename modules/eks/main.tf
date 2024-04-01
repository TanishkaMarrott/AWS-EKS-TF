####### EKS Cluster and Node Group Configuration #######

# Create an AWS EKS Cluster with specific configurations
resource "aws_eks_cluster" "aws-eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.aws-eks-cluster.arn

  vpc_config {
    subnet_ids              = var.aws_private_subnet  # Changed to private subnets
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.eks_worker_nodes_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSVPCResourceController,
  ]
}

# Define a node group within the EKS cluster for managing worker nodes
resource "aws_eks_node_group" "aws-eks-cluster" {
  cluster_name    = aws_eks_cluster.aws-eks-cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.aws-eks-cluster2.arn
  subnet_ids      = var.aws_private_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.eks_worker_nodes_sg.id]
    ec2_ssh_key               = var.key_pair
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Security group for the node group with enhanced security rules
resource "aws_security_group" "eks_worker_nodes_sg" {
  name        = "eks-worker-nodes-sg"
  description = "Security group for EKS worker nodes with enhanced security rules"
  vpc_id      = var.vpc_id

   # Allow SSH access - restrict this to your IP if necessary
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can add your corporate network range
    description = "SSH access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress to essential services"
  }
}

# IAM role for EKS cluster
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
}

# Attach IAM policies required for the EKS cluster and node group operation
resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.aws-eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.aws-eks-cluster.name
}

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
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.aws-eks-cluster2.name
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.aws-eks-cluster2.name
}

resource "aws_iam_role_policy_attachment" "aws-eks-cluster-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.aws-eks-cluster2.name
}
