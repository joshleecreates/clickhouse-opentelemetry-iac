provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
} 

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  version    = "5.27.0" # Update this to the desired version
}

data "kubernetes_secret" "argocd_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  depends_on = [helm_release.argocd]
}

data "kubernetes_service" "argocd-server" {
  metadata {
    name = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
}

output "argocd_password" {
  value     = data.kubernetes_secret.argocd_secret.data["password"]
  sensitive = true
}
