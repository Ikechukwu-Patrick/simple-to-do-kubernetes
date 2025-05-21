resource "kubernetes_namespace" "ci_cd" {
  metadata {
    name = "ci-cd"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.ci_cd.metadata[0].name
  version    = "5.46.8"

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
}