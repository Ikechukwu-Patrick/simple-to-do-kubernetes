output "monitoring" {
  value = {
    grafana    = module.monitoring.grafana_url
    prometheus = module.monitoring.prometheus_url
  }
}

output "database" {
  sensitive = true
  value = {
    host     = "postgresql.database.svc.cluster.local"
    password = var.db_password
  }
}

output "ci_cd" {
  value = {
    argo_cd = module.ci_cd.argo_cd_url
  }
}