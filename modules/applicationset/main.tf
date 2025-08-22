terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }
}
resource "kubernetes_namespace" "" {}