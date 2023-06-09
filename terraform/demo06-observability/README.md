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

### Credentials for Loki

``` shell
export TFSTATE_KEY=terraform-ws/observability
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
aws eks update-kubeconfig --name demo06 --region ap-southeast-1

```

TODO: change prometheus endpoint URL in collector.yaml

``` shell
cd .. # back to parent directory
kubectl apply -f ./collector/collector.yaml
```

``` shell
cd application/hello
get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

if [ ! -z "$1" ]
then
      echo "\$1 is NOT empty - $1"
      export DOCKER_IMAGE_VERSION="$1"
else
      echo "\$1 is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

aws ecr get-login-password --region $CURRENT_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com
docker build . -t grafana-demo-hello:latest
docker tag grafana-demo-hello:latest $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-hello:$DOCKER_IMAGE_VERSION
docker push $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-hello:$DOCKER_IMAGE_VERSION

```

``` shell
cd ../world
#!/bin/bash

get_current_directory() {
    current_file="${PWD}/${0}"
    echo "${current_file%/*}"
}

CWD=$(get_current_directory)
echo "$CWD"

cd $CWD

if [ ! -z "$1" ]
then
      echo "\$1 is NOT empty - $1"
      export DOCKER_IMAGE_VERSION="$1"
else
      echo "\$1 is empty"
      export DOCKER_IMAGE_VERSION="v0.1"
fi

aws ecr get-login-password --region $CURRENT_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com
docker build . -t grafana-demo-world:latest
docker tag grafana-demo-world:latest $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-world:$DOCKER_IMAGE_VERSION
docker push $ACCOUNT_ID.dkr.ecr.$CURRENT_REGION.amazonaws.com/grafana-demo-world:$DOCKER_IMAGE_VERSION

```

### Deploy Application

``` shell
cd ..
kubectl apply -f ./k8s-resources/deployment.yaml
kubectl apply -f ./k8s-resources/service.yaml

```

## Configure Grafana

- Prometheus
- X-Ray
- Loki

## Clean Up

```shell

terraform destroy --auto-approve

```
