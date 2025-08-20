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
    name = var.prefix
    cidr = "10.0.0.0/16"
    azs  = slice(data.aws_availability_zones.available.names, 0, var.azs_count)
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