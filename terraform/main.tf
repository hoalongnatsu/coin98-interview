provider "aws" {
  region = var.region
}

locals {
  tags = {
    project = "interview"
  }
}

data "aws_canonical_user_id" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

output "alb" {
  value = module.ecs_alb.lb_dns_name
}
