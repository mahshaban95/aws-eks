
###################################################################
#######  Providers
###################################################################

module "common" {
  source = "../../modules/common"
}
provider "aws" {
  region = module.common.region

  default_tags {
    tags = module.common.default_tags
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name,  "--region", module.common.region]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name, "--region", module.common.region]
      command     = "aws"
    }
  }
}

################################################################################
# Variables, Locals, and Data Sources
################################################################################

# Retrieve EKS cluster configuration
data "aws_eks_cluster" "cluster" {
  name = module.common.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.common.cluster_name
}

locals {
  cluster_name      = module.common.cluster_name
  cluster_version   = data.aws_eks_cluster.cluster.version
  cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
  oidc_provider_arn = "<OIDC_PROVIDER_ARN>"
}

################################################################################
# EKS Cluster
################################################################################


module "eks-blueprints-addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.16.3"

  cluster_name = local.cluster_name
  cluster_version = local.cluster_version
  cluster_endpoint = local.cluster_endpoint
  oidc_provider_arn = local.oidc_provider_arn

  enable_argocd = true

  argocd = {
    values = [
      <<YAML
nameOverride: argo-cd
redis-ha:
  enabled: false
controller:
  replicas: 1
server:
  replicas: 1
repoServer:
  replicas: 1
applicationSet:
  replicaCount: 1
YAML
  ]
  }
}
