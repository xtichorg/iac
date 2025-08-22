terraform {
  required_version = "~> 1"
}

provider "aws" {
  region = var.aws_region
}

# data "aws_eks_cluster" "main" {
#   name = module.eks.cluster_name
# }
#
# data "aws_eks_cluster_auth" "main" {
#   name = module.eks.cluster_name
# }
#
# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.main.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.main.token
# }

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  tags = {
    project = "iac"
  }
}
