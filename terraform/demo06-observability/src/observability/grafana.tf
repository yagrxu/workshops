locals {
  grafana_config = <<EOT
serviceAccount:
    name: "amp-iamproxy-query-service-account"
    annotations:
        eks.amazonaws.com/role-arn: "arn:aws:iam::${var.account_id}:role/amp-iamproxy-query-role"
grafana.ini:
  auth:
    sigv4_auth_enabled: true
EOT

}

resource "helm_release" "grafana" {
  name = "grafana-demo"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  values     = [local.grafana_config]
  depends_on = [aws_iam_role.amp-iamproxy-query-role]
}

resource "aws_iam_role" "amp-iamproxy-query-role" {
  name = "amp-iamproxy-query-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        }
      },
    ]
  })
  inline_policy {
    name = "amp-iamproxy-query-role-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["aps:*", "xray:*", "ec2:DescribeRegions"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}

resource "kubernetes_ingress_v1" "grafana-demo_ingress" {
  metadata {
    name      = "grafana-demo"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"

      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "grafana-demo"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# data "aws_ssoadmin_instances" "example" {}

# data "aws_identitystore_user" "example" {
#   identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]

#   alternate_identifier {
#     unique_attribute {
#       attribute_path  = "UserName"
#       attribute_value = var.grafana_username
#     }
#   }
# }

# resource "aws_grafana_workspace" "example" {
#   account_access_type      = "CURRENT_ACCOUNT"
#   authentication_providers = ["AWS_SSO"]
#   permission_type          = "SERVICE_MANAGED"
#   role_arn                 = aws_iam_role.assume.arn
#   vpc_configuration {
#     security_group_ids = var.security_group_ids
#     subnet_ids         = var.subnet_ids
#   }
# }

# resource "aws_grafana_role_association" "example" {
#   role         = "ADMIN"
#   user_ids     = [data.aws_identitystore_user.example.user_id]
#   workspace_id = aws_grafana_workspace.example.id
# }

# resource "aws_iam_role" "assume" {
#   name = "${var.cluster_name}-grafana-assume"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "grafana.amazonaws.com"
#         }
#       },
#     ]
#   })

#   inline_policy {
#     name = "Prometheus"

#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = ["*"]
#           Effect   = "Allow"
#           Resource = "*"
#         },
#       ]
#     })
#   }

# }
