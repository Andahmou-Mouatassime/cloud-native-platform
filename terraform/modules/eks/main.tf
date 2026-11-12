
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.29.0"

  # Cluster configuration
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Network configuration
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true

  # Public endpoint accessible depuis toutes les IP
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  # Essential EKS addons

  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
  }

  eks_managed_node_groups = {
    general = {
      name           = "general-workers"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 2
      max_size     = 3
      desired_size = 2

      disk_size = 20
    }
  }

  tags = var.tags
}
