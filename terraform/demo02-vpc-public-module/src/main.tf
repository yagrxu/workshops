
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = var.region
}

locals {
  vpc_cidr = "10.0.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"
  name    = "demo"
  cidr    = local.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
}

