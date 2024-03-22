module "vpc" {
  source                  = "./modules/vpc"
  tags                    = { "Name" = "aws-eks-cluster" }
  instance_tenancy        = "default"
  vpc_cidr                = "10.0.0.0/16"
  access_ip               = "0.0.0.0/0"  #Will adjust 
  public_sn_count         = 2
  public_cidrs            = ["10.0.1.0/24", "10.0.2.0/24"]  # CIDRs for public subnets.
  map_public_ip_on_launch = true
  rt_route_cidr_block     = "0.0.0.0/0"
}

module "eks" {
  source                  = "./modules/eks"
  aws_public_subnet       = module.vpc.aws_public_subnet
  vpc_id                  = module.vpc.vpc_id
  cluster_name            = "module-eks-${random_string.suffix.result}"
  endpoint_public_access  = true
  endpoint_private_access = false
  public_access_cidrs     = ["52.69.121.167/32", "115.96.77.190/32"]  # Restricting Kubernetes API server access - my Ip and Jenkins Server's IP
  node_group_name         = "aws-eks-cluster"
  scaling_desired_size    = 2
  scaling_max_size        = 4
  scaling_min_size        = 1
  instance_types          = ["t3.small"]
  key_pair                = "tanishka-tokyo-ssh-key"
}
