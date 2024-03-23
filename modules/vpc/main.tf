# Defining the VPC for the AWS EKS cluster
resource "aws_vpc" "aws-eks-cluster" {
  cidr_block       = var.vpc_cidr 
  instance_tenancy = var.instance_tenancy
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = var.tags
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "aws-eks-cluster_gw" {
  vpc_id = aws_vpc.aws-eks-cluster.id
  tags = var.tags
}

# List of available Availability Zones for deploying the subnet
data "aws_availability_zones" "available" {
}

# Randomly shuffling the list of available Availability Zones
resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

# Creating public subnets in the VPC
resource "aws_subnet" "public_aws-eks-cluster_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.aws-eks-cluster.id
  cidr_block              = element(var.public_cidrs, count.index)
  availability_zone       = element(random_shuffle.az_list.result, count.index)
  map_public_ip_on_launch = true
  tags = var.tags
  
}

# Creating private subnets in the VPC
resource "aws_subnet" "private_aws-eks-cluster_subnet" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.aws-eks-cluster.id
  cidr_block        = element(var.private_cidrs, count.index)
  availability_zone = element(random_shuffle.az_list.result, count.index)
  map_public_ip_on_launch = false
  tags = var.tags
}

# Associating the default route table with the Internet Gateway
resource "aws_default_route_table" "internal_aws-eks-cluster_default" {
  default_route_table_id = aws_vpc.aws-eks-cluster.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-eks-cluster_gw.id
  }
  tags = var.tags
}
