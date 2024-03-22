####### Outputs for EKS Cluster Configuration #######

# The endpoint URL of the EKS cluster through which the Kubernetes API can be accessed.
output "endpoint" {
  value = aws_eks_cluster.aws-eks-cluster.endpoint
}

# Output the base64-encoded certificate data required to communicate with the cluster securely. This is part of the kubeconfig file.
output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.aws-eks-cluster.certificate_authority[0].data
}

# Output the unique identifier (ID) of the EKS cluster. 
output "cluster_id" {
  value = aws_eks_cluster.aws-eks-cluster.id
}

# Repeat the output for the EKS cluster endpoint URL. 
output "cluster_endpoint" {
  value = aws_eks_cluster.aws-eks-cluster.endpoint
}

# Output the name of the EKS cluster as defined during its creation
output "cluster_name" {
  value = aws_eks_cluster.aws-eks-cluster.name
}
