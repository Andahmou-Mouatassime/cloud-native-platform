
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # NAT Gateway configuration
  enable_nat_gateway = true
  single_nat_gateway = true

  # DNS configuration
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Public subnet configuration
  map_public_ip_on_launch = true

  # Kubernetes subnet discovery tags
  public_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/role/elb"            = "1"
      "kubernetes.io/cluster/${var.name}" = "shared"
    }
  )

  private_subnet_tags = merge(
    var.tags,
    {
      "kubernetes.io/role/internal-elb"   = "1"
      "kubernetes.io/cluster/${var.name}" = "shared"
    }
  )

  tags = var.tags
}
