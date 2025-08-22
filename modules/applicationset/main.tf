terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }
  }
}

resource "helm_release" "applicationset" {
  chart = "${path.module}/helm"
  name  = "applicationset"
  replace = true
}