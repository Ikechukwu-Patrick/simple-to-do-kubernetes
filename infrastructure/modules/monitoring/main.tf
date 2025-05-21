resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  set {
    name  = "grafana.adminPassword"
    value = "admin"
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "false"
  }
}

# Redis Exporter for Prometheus
resource "helm_release" "redis_exporter" {
  name       = "redis-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-redis-exporter"
  namespace  = "monitoring"

  set {
    name  = "redisAddress"
    value = "redis://redis.cache.svc.cluster.local:6379"
  }

  set {
    name  = "redisPassword"
    value = var.redis_password
  }

  depends_on = [helm_release.prometheus]
}

# Pre-configured Redis Dashboard for Grafana
resource "kubernetes_config_map" "redis_dashboard" {
  metadata {
    name      = "redis-dashboard"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "redis-dashboard.json" = file("${path.module}/dashboards/redis-dashboard.json")
  }

  depends_on = [helm_release.prometheus]
}