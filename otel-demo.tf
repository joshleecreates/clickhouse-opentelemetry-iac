provider "helm" {
  kubernetes {
    host                   = module.eks_clickhouse.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_clickhouse.eks_cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name, "--region", local.region]
      command     = "aws"
    }
  }
} 

resource "helm_release" "otel-demo" {
  name       = "clickhouse-opentelemetry-demo"
  repository = "https://joshleecreates.github.io/my-helm-charts"
  chart      = "opentelemetry-demo"
  version    = "0.32.0"
  values = [
    templatefile("${path.module}/otel-demo.yaml.tpl", {
      clickhouse_url = module.eks_clickhouse.clickhouse_cluster_url
      clickhouse_username = "test"
      clickhouse_password = module.eks_clickhouse.clickhouse_cluster_password
      clickhouse_cluster_name = "opentelemetry-demo-cluster"
    })
  ]
}
