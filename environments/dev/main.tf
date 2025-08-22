terraform {
  backend "s3" {
    bucket       = "tf-state-bucket-iac"
    key          = "xtichorg/iac/dev"
    region       = "us-east-1"
    use_lockfile = true
  }
}

module "aws_eks" {
  source = "../../infrastructure/aws"

  aws_region = "us-east-1"
  prefix = "dev"
  azs_count = 3

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

module "argocd" {
  source = "../../infrastructure/argocd"

  depends_on = [module.aws_eks]
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${module.aws_eks.aws_region} --name ${module.aws_eks.eks.cluster_name}"
}