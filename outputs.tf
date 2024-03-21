# Provides the unique identifier of the EKS cluster --> for integration with other AWS services or Terraform modules.
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

# Endpoint URL of the EKS cluster's control plane. We'll use this for configuring kubectl & other Kubernetes management tools.
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

# For referencing the cluster
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}
