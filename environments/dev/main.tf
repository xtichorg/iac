terraform {
  required_version = "~> 1"

  backend "s3" {
    bucket       = "tf-state-bucket-iac"
    key          = "xtichorg/iac/dev"
    region       = "us-east-1"
    use_lockfile = true
  }
}

locals {
  aws_region = "us-east-1"
  prefix     = "dev"
  azs_count  = 3
}

module "aws_eks" {
  source = "../../infrastructure/aws"

  prefix    = local.prefix
  azs_count = local.azs_count

  providers = {
    aws = aws
  }

}

module "argocd" {
  source = "../../infrastructure/argocd"

  providers = {
    helm = helm
  }

  depends_on = [module.aws_eks]
}

module "applicationset" {
  source = "../../modules/applicationset"

  providers = {
    helm = helm
  }

  depends_on = [module.argocd]
}

data "aws_eks_cluster" "main" {
  name = module.aws_eks.eks.cluster_name

  depends_on = [module.aws_eks]
}

data "aws_eks_cluster_auth" "main" {
  name = module.aws_eks.eks.cluster_name

  depends_on = [module.aws_eks]
}


output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${module.aws_eks.aws_region} --name ${module.aws_eks.eks.cluster_name}"
}