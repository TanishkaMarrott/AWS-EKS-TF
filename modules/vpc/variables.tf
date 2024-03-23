# The CIDR block for the VPC that will be created
variable "vpc_cidr" {
  description = "The CIDR block for the AWS VPC."
  type        = string
  default     = "10.0.0.0/16"
}

# The IP address that will be allowed access to the VPC (specifically for the NAT Gateway and Security Group rules)
variable "access_ip" {
  description = "The IP address range that will be allowed access to the VPC."
  type        = string
  default     = "0.0.0.0/0"
}

# The number of public subnets to create within the VPC
variable "public_sn_count" {
  description = "The number of public subnets to create within the VPC."
  type        = number
  default     = 2
}

# A list of CIDR blocks for the public subnets within the VPC
variable "public_cidrs" {
  description = "A list of CIDR blocks for the public subnets within the VPC."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# The instance tenancy of the VPC
variable "instance_tenancy" {
  description = "The instance tenancy option for the VPC."
  type        = string
  default     = "default"
}

# Tags to be applied to all resources created
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {
    "Project" = "AWS EKS Setup"
    "Environment" = "Development"
  }
}

# A list of CIDR blocks for the private subnets within the VPC
variable "private_cidrs" {
  description = "A list of CIDR blocks for the private subnets within the VPC."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Whether instances launched in public subnets should automatically be assigned a public IP address.
variable "map_public_ip_on_launch" {
  description = "Determines whether instances launched in public subnets should be assigned a public IP address."
  type        = bool
  default     = true
}

# The CIDR block for the route in the VPC's route table that directs traffic to the internet gateway
variable "rt_route_cidr_block" {
  description = "The CIDR block for the route in the VPC's route table that directs traffic to the internet gateway."
  type        = string
  default     = "0.0.0.0/0"
}
