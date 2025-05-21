resource "kubernetes_horizontal_pod_autoscaler" "app" {
  metadata {
    name = "${var.app_name}-hpa"
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }
    min_replicas = 2
    max_replicas = 4
    target_cpu_utilization_percentage = 80
  }
}