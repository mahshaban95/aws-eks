# ################################################################################
# # 00-infra
# ################################################################################

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}
output "region" {
  value = var.region
}


variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
  default     = "fawaterak"
}
output "cluster_name" {
  value = var.cluster_name
}

variable "tag_env_name" {
  description = "Environment"
  type        = string
  default     = "Dev"
}

variable "tag_owner" {
  description = "Owner"
  type        = string
  default     = "Mahmoud Shaaban"
}

variable "tag_project" {
  description = "Project"
  type        = string
  default     = "Fawaterak K8s"
}

output "default_tags" {
  value = {
    Environment = var.tag_env_name
    Owner       = var.tag_owner
    Project     = var.tag_project
  }
}


# ################################################################################
# # 10-platform
# ################################################################################







