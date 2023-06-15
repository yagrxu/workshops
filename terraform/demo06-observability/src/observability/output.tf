output "prometheus_endpoint" {
  value = aws_prometheus_workspace.prom.prometheus_endpoint
}
