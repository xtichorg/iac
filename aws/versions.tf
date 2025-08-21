terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }

    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "~> 2"
    # }
  }
}