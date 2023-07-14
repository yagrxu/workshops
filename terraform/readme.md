# Terraform Workshop

## Prerequisites

### Cloud9 Initialization

``` shell
DEFAULT_VPC_ID=`aws ec2 describe-vpcs --region $AWS_REGION | jq .Vpcs[0].VpcId -r`
DEFAULT_SUBNET_ID=`aws ec2 describe-subnets --region $AWS_REGION --filter Name=vpc-id,Values=$DEFAULT_VPC_ID | jq .Subnets[1].SubnetId -r`

aws cloud9 create-environment-ec2 --name devax-workshop \
--description "This environment is for demo" \
--instance-type m5.xlarge \
--image-id resolve:ssm:/aws/service/cloud9/amis/amazonlinux-2-x86_64 \
--region $AWS_REGION \
--connection-type CONNECT_SSH --subnet-id $DEFAULT_SUBNET_ID
```

### Cloud9 Envinronment Setup

Workshop is planned in ap-southeast-1 region and this will be set as environment variable from very beginning

``` shell
sudo bash
yum install jq -y
export CURRENT_REGION="ap-southeast-1"
export ACCOUNT_ID=`aws sts get-caller-identity | jq .Account -r`
aws s3 mb s3://my-tfstate-$ACCOUNT_ID --region $CURRENT_REGION
```

Copy EventEngine credentials to environment

### Install Kubectl

```shell
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.17/2023-05-11/bin/linux/amd64/kubectl
chmod u+x kubectl
mv kubectl /usr/bin/kubectl
```
