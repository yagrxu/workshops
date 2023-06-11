# EKS from Public Module

## Files Structure

```shell
.
├── alb-controller.tf
├── data.tf
├── main.tf
├── provider.tf
├── variables.tf
└── versions.tf
```

## Critical Content

``` terraform
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.3"
  # ...
  }
```

``` terraform
module "vpc" {
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # 对于使用karpenter做资源管理的集群来说，需要给资源所在的子网打tag来进行识别。
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
    "kubernetes.io/role/internal-elb"           = 1
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

}
```

## Run Through

``` shell
export TFSTATE_KEY=terraform-ws/observability
export TFSTATE_BUCKET=$(aws s3 ls --output text | awk '{print $3}' | grep tfstate-)
export TFSTATE_REGION=us-east-1
export TF_VAR_region=us-east-1

```

```shell

terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

```

```shell

terraform plan

```

```shell

terraform apply --auto-approve

```

## Import Existing VPC

### Create a new VPC

```shell
export DEFAULT_REGION=us-east-1
export VPC_ID=`aws ec2 create-vpc --cidr-block 10.0.0.0/16 --region $DEFAULT_REGION | jq -r .Vpc.VpcId`
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value='another vpc' --region $DEFAULT_REGION
export SUBNET_ID=`aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.10.0/24 --region $DEFAULT_REGION | jq -r .Subnet.SubnetId`

# export IGW_ID=`aws ec2 create-internet-gateway --region $DEFAULT_REGION | jq -r .InternetGateway.InternetGatewayId`

# aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID

```

### Prepare Resource

```terraform

locals {
  demo_cidr         = "10.1.1.0/24"
  imported_vpc_cidr = "10.1.0.0/16"
}

resource "aws_vpc" "demo" {
  cidr_block = local.imported_vpc_cidr
  tags = {
    Name = "imported VPC"
  }
}

resource "aws_subnet" "demo" {
  vpc_id     = aws_vpc.demo.id
  cidr_block = local.demo_cidr
  # availability_zone = "us-east-1a"
}

```

```shell
terraform import aws_vpc.demo $VPC_ID
terraform import aws_subnet.demo $SUBNET_ID
```

## Setup Transit Gateway

```terraform

resource "aws_ec2_transit_gateway" "demo" {
  description = "demo"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_module_public_subnets_attachment" {
  subnet_ids         = module.vpc.public_subnets
  transit_gateway_id = aws_ec2_transit_gateway.demo.id
  vpc_id             = module.vpc.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_imported_subnets_attachment" {
  subnet_ids         = [aws_subnet.demo.id]
  transit_gateway_id = aws_ec2_transit_gateway.demo.id
  vpc_id             = aws_vpc.demo.id
}

data "aws_route_tables" "public_module_route_tables" {
  vpc_id = module.vpc.vpc_id

  # filter {
  #   name   = "tag:kubernetes.io/kops/role"
  #   values = ["private*"]
  # }
}

data "aws_route_table" "imported_vpc_route_table" {
  vpc_id = aws_vpc.demo.id
}

resource "aws_route" "public_module_vpc_route" {
  count                  = length(data.aws_route_tables.public_module_route_tables.ids)
  route_table_id         = tolist(data.aws_route_tables.public_module_route_tables.ids)[count.index]
  destination_cidr_block = local.imported_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo.id
}

resource "aws_route" "imported_vpc_route" {
  count                  = length(module.vpc.private_subnets_cidr_blocks)
  route_table_id         = data.aws_route_table.imported_vpc_route_table.id
  destination_cidr_block = local.vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.demo.id
}

```

## Clean Up

```shell

terraform destroy --auto-approve

```
