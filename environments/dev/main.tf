terraform {
  required_version = "~> 1"

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
  prefix     = "dev"
  azs_count  = 3

}

module "argocd" {
  source = "../../infrastructure/argocd"

  depends_on = [module.aws_eks]
}

module "applicationset" {
  source = "../../modules/applicationset"

  manifest_yaml = "./appset.yaml"

  depends_on = [module.argocd]
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

data "aws_eks_cluster" "main" {
  name = module.aws_eks.eks.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = module.aws_eks.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.main.token
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${module.aws_eks.aws_region} --name ${module.aws_eks.eks.cluster_name}"
}