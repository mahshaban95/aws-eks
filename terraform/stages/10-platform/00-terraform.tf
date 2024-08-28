terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.64.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}
