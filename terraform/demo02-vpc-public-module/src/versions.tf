terraform {
  required_providers {
    aws = {
      # https://github.com/hashicorp/terraform-provider-aws
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
    }
  }
  backend "s3" {
    # bucket = "s3-bucket-name"
    # key    = "terraform-ws/vpc-plain"
    # region = "us-east-1"
  }
}
