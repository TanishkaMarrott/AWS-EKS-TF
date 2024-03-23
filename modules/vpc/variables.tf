# The CIDR block for the VPC that will be created
variable "vpc_cidr" {}

# The IP address that will be allowed access to the VPC
variable "access_ip" {}

# The number of public subnets to create within the VPC
variable "public_sn_count" {}

# A list of CIDR blocks for the public subnets within the VPC
variable "public_cidrs" {
  type = list(any)
}

variable "instance_tenancy" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "private_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"] 
}


# Whether instances launched in public subnets should automatically be assigned a public IP address.
variable "map_public_ip_on_launch" {}

# The CIDR block for the route in the VPC's route table that directs traffic to the internet gateway
variable "rt_route_cidr_block" {}
