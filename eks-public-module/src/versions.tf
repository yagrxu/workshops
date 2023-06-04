terraform {
  required_providers {
    aws = {
      # https://github.com/hashicorp/terraform-provider-aws
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
  }
  backend "s3" {
    # bucket = "s3-bucket-name"
    # key    = "terraform-ws/vpc-plain"
    # region = "us-east-1"
  }
}
