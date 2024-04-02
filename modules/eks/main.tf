####### EKS Cluster and Node Group Configuration #######

# EKS Cluster Configuration
resource "aws_eks_cluster" "aws-eks-cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.aws-eks-cluster.arn

  vpc_config {
    subnet_ids              = var.aws_private_subnet
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

# On-Demand Node Group
resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.aws-eks-cluster.name
  node_group_name = "${var.node_group_name}-on-demand"
  node_role_arn   = aws_iam_role.aws-eks-cluster2.arn
  subnet_ids      = var.aws_private_subnet
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  capacity_type = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Spot Instance Node Group
resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.aws-eks-cluster.name
  node_group_name = "${var.node_group_name}-spot"
  node_role_arn   = aws_iam_role.aws-eks-cluster2.arn
  subnet_ids      = var.aws_private_subnet
  instance_types  = ["t3.medium", "m4.large"] # Provide multiple instance types for flexibility

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  capacity_type = "SPOT"

  depends_on = [
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.aws-eks-cluster-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Enhanced Security Group for Worker Nodes
resource "aws_security_group" "eks_worker_nodes_sg" {
  name        = "eks-worker-nodes-sg"
  description = "Security group for EKS worker nodes with enhanced security rules"
  vpc_id      = var.vpc_id

  # Allow SSH access - restrict this to your IP if necessary
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can add your corporate network range here
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
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
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

# IAM Role for the node group to assume EC2 Service
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
