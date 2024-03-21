###### vpc/outputs.tf

# List of IDs for the public subnets created within the AWS EKS cluster's VPC
output "aws_public_subnet" {
  value = aws_subnet.public_aws-eks-cluster_subnet.*.id
}

# The ID of the VPC created for the AWS EKS cluster
output "vpc_id" {
  value = aws_vpc.aws-eks-cluster.id
}
