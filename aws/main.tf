provider "aws"{
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  vpc = {
    name = "${var.prefix}-vpc"
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
  }

  eks = {
    name = "${var.prefix}-eks"
    kubernetes_version = "1.33"
    min_size = 2
    max_size = 6
    desired_size = 2
    retantion_in_days = 3
  }

  tags = {
    project = "iac"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = local.vpc.name
  cidr = local.vpc.cidr

  azs = local.vpc.azs
  private_subnets = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 4, k)]
  public_subnets  = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true
  
    public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 21.1"

  name = local.eks.name
  kubernetes_version = local.eks.kubernetes_version

  # not for prod:
  deletion_protection = false
  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true


  cloudwatch_log_group_retention_in_days = local.eks.retantion_in_days

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    "${var.prefix}-eks-nodegroup" = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.small"]
      capacity_type = "SPOT"

      min_size = local.eks.min_size
      max_size = local.eks.max_size
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = local.eks.desired_size

      # This is not required - demonstrates how to pass additional configuration
      # Ref https://bottlerocket.dev/en/os/1.19.x/api/settings/
      bootstrap_extra_args = <<-EOT
        # The admin host container provides SSH access and runs with "superpowers".
        # It is disabled by default, but can be disabled explicitly.
        [settings.host-containers.admin]
        enabled = false

        # The control host container provides out-of-band access via SSM.
        # It is enabled by default, and can be disabled if you do not expect to use SSM.
        # This could leave you with no way to access the API and change settings on an existing node!
        [settings.host-containers.control]
        enabled = true

        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }
}
