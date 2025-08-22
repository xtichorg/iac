terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
}

variable "manifest_yaml" {
  type = string
}

resource "kubernetes_manifest" "applicationset" {
  manifest = yamldecode(file(var.manifest_yaml))
}