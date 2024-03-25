module "vpc" {
  source                  = "./modules/vpc"
  instance_tenancy        = "default"
  vpc_cidr                = "10.0.0.0/16"
  access_ip               = "0.0.0.0/0"  #Will adjust 
  public_sn_count         = 2
  public_cidrs            = ["10.0.1.0/24", "10.0.2.0/24"]  # CIDRs for public subnets.
  private_cidrs           =  ["10.0.3.0/24", "10.0.4.0/24"] 
  map_public_ip_on_launch = true
  rt_route_cidr_block     = "0.0.0.0/0"
   tags = {
    "Name" = "aws-eks-cluster",
    "Environment" = "Production"
  }
}

module "eks" {
  source                  = "./modules/eks"
  # Use the private subnet IDs for the node group. 
  aws_private_subnet      = module.vpc.aws_private_subnet
  aws_public_subnet       = module.vpc.aws_public_subnet
  vpc_id                  = module.vpc.vpc_id
  cluster_name            = "module-eks-${random_string.suffix.result}"
  endpoint_public_access  = true
  endpoint_private_access = true  # Typically, you'd want private access enabled if your node groups are in private subnets.
  public_access_cidrs     = data.external.instance_connect_ips.result["ips"]
  node_group_name         = "aws-eks-cluster"
  scaling_desired_size    = 2
  scaling_max_size        = 2
  scaling_min_size        = 1
  instance_types          = ["t3.small"]
  key_pair                = "tanishka-tokyo-ssh-key"
}

data "external" "instance_connect_ips" {
  program = ["python3", "${path.module}/scripts/fetch_instance_connect_ips.py", "ap-northeast-1"]

}
