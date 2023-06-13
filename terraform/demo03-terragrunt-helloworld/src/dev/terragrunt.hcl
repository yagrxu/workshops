# dev/terragrunt.hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = get_env("TFSTATE_BUCKET", "")

    key = "terragrunt/demo/dev"
    region         = get_env("DEFAULT_REGION", "us-east-1")
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=4.0.2"
}

# Indicate what region to deploy the resources into
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region = get_env("DEFAULT_REGION", "us-east-1")
  version = "~> 4.52.0"
}
EOF
}

# Indicate the input values to use for the variables of the module.
inputs = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}