# VPC Plain HCL Demo

## Files Structure

```shell
.
├── main.tf
├── variables.tf
└── versions.tf
```

## Critical Content

```terraform
  required_providers {
    aws = {
      # https://github.com/hashicorp/terraform-provider-aws
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
    }
  }
```

## Run Through

``` shell
export TFSTATE_KEY=terraform-ws/vpc-plain
export TFSTATE_BUCKET=my-tfstate-$ACCOUNT_ID
export TFSTATE_REGION=$CURRENT_REGION
export TF_VAR_region=$CURRENT_REGION

```

```shell

cd src
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

```

```shell

terraform plan

```

```shell

terraform apply --auto-approve

```

```shell

terraform destroy --auto-approve

```

## Have your Own Module

```shell
cd .. # move to upper folder
mkdir -p modules/vpc
cp src/main.tf modules/vpc/main.tf
cp src/variables.tf modules/vpc/variables.tf
cp module-demo/main.tf main.tf
```

```shell
export TFSTATE_KEY=terraform-ws/vpc-plain-modules
export TFSTATE_BUCKET=my-tfstate-$ACCOUNT_ID
export TFSTATE_REGION=$CURRENT_REGION
export TF_VAR_region=$CURRENT_REGION
```

```shell
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}" -reconfigure
```

```shell

terraform apply --auto-approve
```

## Clean Up

```shell

terraform destroy --auto-approve

```
