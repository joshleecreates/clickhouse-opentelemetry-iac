resource "helm_release" "otel-demo" {
  name       = "clickhouse-opentelemetry-demo"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-demo"
  version    = "0.28.3"
  values = [
    templatefile("${path.module}/otel-demo.yaml.tpl", {
      clickhouse_url = module.eks_clickhouse.clickhouse_cluster_url
      clickhouse_username = "test"
      clickhouse_password = module.eks_clickhouse.clickhouse_cluster_password
    })
  ]
}
