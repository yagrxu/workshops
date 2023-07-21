# workshops

## 使用SageMaker 部署大语言模型

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
                "s3:Put*"
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

## 改写并部署 Lambda 程序

对于部署 Lambda，该用户需要如下权限策略：

调试 SAM 和部署 Lambda 的 IAM User 的附加策略如下：

调试本地 SAM 代码：

```shell
sam sync --stack-name stack-spring-demo-llm --watch
```

系统会自动创建 `stack-spring-demo-llm-***` 的一系列资源，下面的 Policy 限制了删除的资源类型。

当前需要给 AKSK 添加如下的权限：

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:*",
                "lambda:*",
                "execute-api:Invoke",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "apigateway:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::*:role/stack-spring-demo-llm*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteBucket"
            ],
            "Resource": "arn:aws:iam::*:role/stack-spring-demo-llm*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteRole"
            ],
            "Resource": "arn:aws:iam::*:role/stack-spring-demo-llm*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DetachRolePolicy"
            ],
            "Resource": "arn:aws:iam::*:role/stack-spring-demo-llm*"
        }
    ]
}
```

当 Lambda 部署到线上，SAM 会创建一个 Lambda 的执行角色，形如： `stack-spring-demo-llm-xxxx`。

如果需要 Lambda 调用 SageMaker Endpoint, 需要给此角色 SageMaker 的执行权限 `sagemaker:InvokeEndpoint`。

在本 DEMO 中，我们直接给系统的策略：`AmazonSageMakerFullAccess`

---
参考：

<https://sagemaker.readthedocs.io/en/stable/frameworks/huggingface/sagemaker.huggingface.html>

<https://huggingface.co/docs/sagemaker/inference>
