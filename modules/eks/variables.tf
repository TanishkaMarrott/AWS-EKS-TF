#######modules/eks/variables.tf

variable "aws_public_subnet" {}

variable "aws_private_subnet" {}

variable "vpc_id" {}

variable "cluster_name" {}

variable "endpoint_private_access" {}

variable "endpoint_public_access" {}

variable "public_access_cidrs" {
  description = "CIDR blocks for public access to the EKS clsuster API"
}


variable "node_group_name" {}

variable "scaling_desired_size" {}

variable "scaling_max_size" {}

variable "scaling_min_size" {}

variable "instance_types" {}

variable "key_pair" {}
