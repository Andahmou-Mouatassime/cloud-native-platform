
# Discover available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Network infrastructure
module "vpc" {
  source = "../../modules/vpc"

  name = local.name
  cidr = var.vpc_cidr

  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  tags = local.common_tags
}



# Kubernetes infrastructure
module "eks" {
  source = "../../modules/eks"

  cluster_name       = local.name
  kubernetes_version = "1.37"

  # Connect EKS to the VPC
  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnets

  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  tags = local.common_tags
}
