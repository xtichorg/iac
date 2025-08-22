terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }
  }
}

resource "helm_release" "argocd" {
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  name             = "argo-cd"
  version          = "8.3.0"
  namespace        = "argocd"
  create_namespace = true
  replace          = true

  set = [
    {
      name  = "crds.keep"
      value = "false"
    },
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]
}