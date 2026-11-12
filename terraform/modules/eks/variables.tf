
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "endpoint_public_access_cidrs" {
  description = "Allowed CIDRs for EKS public endpoint"
  type        = list(string)
}

variable "tags" {
  description = "Common AWS resource tags"
  type        = map(string)
  default     = {}
}
