# provider "kubernetes" {
#   host                   = module.eks_clickhouse.eks_cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_clickhouse.eks_cluster_ca_certificate)
#
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name, "--region", local.region]
#     command     = "aws"
#   }
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = module.eks_clickhouse.eks_cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_clickhouse.eks_cluster_ca_certificate)
#
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", local.eks_cluster_name, "--region", local.region]
#       command     = "aws"
#     }
#   }
# } 
#
# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }
#
# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = kubernetes_namespace.argocd.metadata.0.name
#   version    = "5.27.0" # Update this to the desired version
#
#   # Additional configuration values
#   set {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }
# }
#
# data "kubernetes_secret" "argocd_secret" {
#   metadata {
#     name      = "argocd-initial-admin-secret"
#     namespace = kubernetes_namespace.argocd.metadata.0.name
#   }
#
#   depends_on = [helm_release.argocd]
# }
#
# output "argocd_password" {
#   value     = data.kubernetes_secret.argocd_secret.data["password"]
#   sensitive = true
# }
