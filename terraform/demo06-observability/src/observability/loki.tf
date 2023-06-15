locals {
  loki_storage = <<EOT
loki:
  auth_enabled: false
  storage:
    bucketNames:
      chunks: ${var.cluster_name}-loki-yagr
      ruler: ${var.cluster_name}-loki-yagr
      admin: ${var.cluster_name}-loki-yagr
    type: s3
    s3:
      s3: ${var.cluster_name}-loki-yagr
      endpoint: s3.${var.region}.amazonaws.com
      region: ${var.region}
      secretAccessKey: ${aws_iam_access_key.loki_user_key.secret}
      accessKeyId: ${aws_iam_access_key.loki_user_key.id}
      s3ForcePathStyle: false
      insecure: false
EOT

}

resource "aws_s3_bucket" "loki" {
  bucket        = "${var.cluster_name}-loki-yagr"
  force_destroy = true
}

resource "helm_release" "loki" {
  name = "loki"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"

  values = [local.loki_storage]
}

resource "helm_release" "fluentbit" {
  name = "fluentbit"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "fluent-bit"

  set {
    name  = "loki.serviceName"
    value = "loki-write.default.svc.cluster.local"
  }
}

resource "kubernetes_ingress_v1" "loki_read_ingress" {
  metadata {
    name      = "loki-read-ingress"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internal"

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
              name = "loki-read"

              port {
                number = 3100
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_iam_access_key" "loki_user_key" {
  user = aws_iam_user.loki_user.name
}

resource "aws_iam_user" "loki_user" {
  name = "loki_user"
  path = "/system/"
}

data "aws_iam_policy_document" "loki_user_doc" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "loki_user_policy" {
  name   = "loki_user_policy"
  user   = aws_iam_user.loki_user.name
  policy = data.aws_iam_policy_document.loki_user_doc.json
}
