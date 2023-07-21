# workshops

## 本地开发环境准备

### 创建 SageMaker 执行角色

创建一个  HuggingfaceExecuteRole （名称可定义）角色，权限如下：

- 可信实体：AWS 服务
- 使用案例：SageMaker-Excution

还需要给此角色加上 S3 的相应权限，如: AmazonS3ReadOnlyAccess

### 本地AKSK权限设置

AKSK 对应的 IAM User 需要的权限：

对于 SageMaker 部署管理，需要如下的权限策略：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::*:role/HuggingfaceExecuteRole"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:List*",
                "s3:Get*",
                "s3:PutObject"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreateModel",
                "sagemaker:CreateEndpointConfig",
                "sagemaker:CreateEndpoint",
                "sagemaker:InvokeEndpoint",
                "sagemaker:DescribeEndpoint",
                "sagemaker:DescribeEndpointConfig",
                "sagemaker:DeleteEndpoint",
                "sagemaker:DeleteModel",
                "sagemaker:DeleteEndpointConfig"
            ],
            "Resource": "*"
        }
    ]
}
```

对于部署 Lambda，该用户需要如下权限策略：

---
参考：

<https://sagemaker.readthedocs.io/en/stable/frameworks/huggingface/sagemaker.huggingface.html>

<https://huggingface.co/docs/sagemaker/inference>
