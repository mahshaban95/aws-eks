###################################################################
#######  Providers
###################################################################

# The AWS provider is needed but we will get it from the shared module
module "common" {
  source = "../../modules/common"
}
provider "aws" {
  region = module.common.region

  default_tags {
    tags = module.common.default_tags
  }
}

################################################################################
# Variables, Locals, and Data Sources
################################################################################

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {}
locals {
  vpc_cidr        = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
}

################################################################################
# Networking
################################################################################


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = module.common.cluster_name
  azs  = local.azs
  cidr = local.vpc_cidr

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.128.0/23", "10.0.130.0/23"]
 
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

###################################################################
#######  Outputs
###################################################################

output "vpc_id" {
  value = module.vpc.vpc_id
  description = "The ID of the VPC"
}