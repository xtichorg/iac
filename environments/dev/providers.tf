provider "aws" {
  region = local.aws_region
}

provider "helm" {
  kubernetes = {
    host                   = module.aws_eks.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_eks.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.aws_eks.eks.cluster_name]
    }
  }
}