# Defining the VPC for the AWS EKS cluster
resource "aws_vpc" "aws-eks-cluster" {
  cidr_block       = var.vpc_cidr 
  instance_tenancy = var.instance_tenancy
  tags = {
    Name = var.tags
  }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "aws-eks-cluster_gw" {
  vpc_id = aws_vpc.aws-eks-cluster.id

  tags = {
    Name = var.tags
  }
}

# List of available Availability Zones for deploying the subnet in ap-northeast-1
data "aws_availability_zones" "available" {
}

# Randomly shuffling the list of available Availability Zones to select a subset for deploying subnets
resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

# Creating public subnets in the VPC in the selected Availability Zones
resource "aws_subnet" "public_aws-eks-cluster_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.aws-eks-cluster.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.tags
  }
}

# Associating the default route table with a route to IG for outbound internet access
resource "aws_default_route_table" "internal_aws-eks-cluster_default" {
  default_route_table_id = aws_vpc.aws-eks-cluster.default_route_table_id

  route {
    cidr_block = var.rt_route_cidr_block
    gateway_id = aws_internet_gateway.aws-eks-cluster_gw.id
  }
  tags = {
    Name = var.tags
  }
}

# Associating these public subnets with the default route table for internet connectivity
resource "aws_route_table_association" "default" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_aws-eks-cluster_subnet[count.index].id
  route_table_id = aws_default_route_table.internal_aws-eks-cluster_default.id
}
