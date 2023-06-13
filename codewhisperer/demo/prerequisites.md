# Work With Cloud9

``` shell
CURRENT_REGION=`aws configure get region`

if [ ! -z "$CURRENT_REGION"]
then
  echo "use default region $CURRENT_REGION"
else
  echo "use default region ap-southeast-1"
  CURRENT_REGION="ap-southeast-1"
fi

DEFAULT_VPC_ID=`aws ec2 describe-vpcs --region ap-southeast-1 | jq .Vpcs[0].VpcId -r`
DEFAULT_SUBNET_ID=`aws ec2 describe-subnets --region ap-southeast-1 --filter Name=vpc-id,Values=$DEFAULT_VPC_ID | jq .Subnets[0].SubnetId -r`

aws cloud9 create-environment-ec2 --name demo \
--description "This environment is for demo" \
--instance-type m5.xlarge \
--image-id resolve:ssm:/aws/service/cloud9/amis/amazonlinux-2-x86_64 \
--region $CURRENT_REGION \
--connection-type CONNECT_SSH --subnet-id $DEFAULT_SUBNET_ID

```
