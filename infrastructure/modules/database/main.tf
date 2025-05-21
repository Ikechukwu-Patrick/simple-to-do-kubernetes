resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = "database"
  create_namespace = true

  set {
    name  = "auth.postgresPassword"
    value = var.db_password
  }

  set {
    name  = "persistence.size"
    value = "5Gi"
  }
}