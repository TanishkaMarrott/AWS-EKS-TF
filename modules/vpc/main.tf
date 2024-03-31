# Define the VPC for the EKS cluster
resource "aws_vpc" "aws-eks-cluster" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.tags
}

# Create an Internet Gateway for the VPC to allow communication with the internet
resource "aws_internet_gateway" "aws-eks-cluster_gw" {
  vpc_id = aws_vpc.aws-eks-cluster.id
  tags   = var.tags
}

# Data source to fetch the list of available Availability Zones
data "aws_availability_zones" "available" {}

# Randomize the selection of Availability Zones to use for the subnets
resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

# Create public subnets for the EKS cluster
resource "aws_subnet" "public_aws-eks-cluster_subnet" {
  count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.aws-eks-cluster.id
  cidr_block              = element(var.public_cidrs, count.index)
  availability_zone       = element(random_shuffle.az_list.result, count.index)
  map_public_ip_on_launch = true
  tags                    = var.tags
}

# Create private subnets for the EKS cluster
resource "aws_subnet" "private_aws-eks-cluster_subnet" {
  count             = length(var.private_cidrs)
  vpc_id            = aws_vpc.aws-eks-cluster.id
  cidr_block        = element(var.private_cidrs, count.index)
  availability_zone = element(random_shuffle.az_list.result, count.index)
  tags              = var.tags
}

# Allocate Elastic IPs for the NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_cidrs)
  tags  = var.tags
}

# Create a NAT Gateway in each public subnet for high availability
resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public_aws-eks-cluster_subnet.*.id, count.index)
  tags          = var.tags
}

# Create route tables for the private subnets
resource "aws_route_table" "private" {
  count = length(var.private_cidrs)
  vpc_id = aws_vpc.aws-eks-cluster.id
  tags   = var.tags
}

# Add routes to the private route tables to route internet-bound traffic through the NAT Gateways
resource "aws_route" "private_nat" {
  count                  = length(var.private_cidrs)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gw.*.id, count.index)
}

# Associate the private subnets with their corresponding route tables
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidrs)
  subnet_id      = element(aws_subnet.private_aws-eks-cluster_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# Configure the default route table for the VPC to route internet-bound traffic through the Internet Gateway
resource "aws_default_route_table" "internal_aws-eks-cluster_default" {
  default_route_table_id = aws_vpc.aws-eks-cluster.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-eks-cluster_gw.id
  }
  tags = var.tags
}
