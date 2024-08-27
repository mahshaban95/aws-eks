###################################################################
#######  Providers
###################################################################

# No extrat providers needed here

################################################################################
# Variables, Locals, and Data Sources
################################################################################

# data "aws_iam_role" "eks_admin" {
#   name = "eks-admin-role"
# }

locals {
  cluster_version = "1.30"
  eks_admin_policy = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

################################################################################
# EKS Cluster
################################################################################


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.13.0"

  cluster_name    = module.common.cluster_name
  cluster_version = local.cluster_version

  cluster_endpoint_public_access = true
  cluster_addons = {
    coredns                = {
      most_recent = true
    }
    kube-proxy             = {
      most_recent = true
    }
    vpc-cni                = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET     = "1"
        }
      })
    }

  }
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  authentication_mode = "API"


  eks_managed_node_groups = {
    micro = {
      ami_type       = "BOTTLEROCKET_ARM_64"
      instance_types = ["t4g.micro"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 2
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size = 1

    }
    # medium = {
    #   ami_type       = "BOTTLEROCKET_ARM_64"
    #   instance_types = ["t4g.medium"]
    #   capacity_type  = "ON_DEMAND"
    #   min_size       = 1
    #   max_size       = 2
    #   # This value is ignored after the initial creation
    #   # https://github.com/bryantbiggs/eks-desired-size-hack
    #   desired_size = 1

    # }
  }



  enable_cluster_creator_admin_permissions = true

  # access_entries = {
  #   # One access entry with a policy associated
  #   admin = {
  #     principal_arn = data.aws_iam_role.eks_admin.arn
  #     policy_associations = {
  #       admin = {
  #         policy_arn = local.eks_admin_policy
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }
  depends_on = [ module.vpc ]
}

###################################################################
#######  Outputs
###################################################################

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
  description = "The ARN of the EKS cluster"
}
