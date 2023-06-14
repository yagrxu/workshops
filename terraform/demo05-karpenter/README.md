# Karpenter for EKS

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
export TFSTATE_KEY=terraform-ws/karpenter
export TFSTATE_BUCKET=my-tfstate-$ACCOUNT_ID
export TFSTATE_REGION=$CURRENT_REGION
export TF_VAR_region=$CURRENT_REGION

```

```shell

cd src # move to upper folder
terraform init -backend-config="bucket=${TFSTATE_BUCKET}" -backend-config="key=${TFSTATE_KEY}" -backend-config="region=${TFSTATE_REGION}"

```

```shell

terraform plan

```

```shell

terraform apply --auto-approve

```

## Configure Kubectl

``` shell
aws eks update-kubeconfig --name demo05  --kubeconfig ~/.kube/config --region ap-southeast-1 --alias demo05

```

## Test Karpenter

### Load Generator

refer to this page [HorizontalPodAutoscaler Walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

``` shell
kubectl apply -f https://k8s.io/examples/application/php-apache.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=100
kubectl run -i --tty load-generator01 --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
kubectl run -i --tty load-generator02 --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
kubectl run -i --tty load-generator03 --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

# kubectl --generator=run-pod/v1 run -i --tty load-generator --image=busybox /bin/sh
```

```shell
watch -n 5 kubectl get hpa
watch -n 5 kubectl get pods -A
```

## Clean Up

```shell

terraform destroy --auto-approve

```
