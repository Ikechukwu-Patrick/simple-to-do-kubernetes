resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_name}-${var.environment}"
    labels = {
      app = var.app_name
      env = var.environment
    }
  }

  spec {
    replicas = var.replica_count
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
          env = var.environment
        }
      }
      spec {
        container {
          name  = "${var.app_name}-container"
          image = "your-registry/${var.app_name}:${var.image_version}"
          port {
            container_port = 3000
          }
          env {
            name  = "S3_BUCKET"
            value = var.s3_bucket_name
          }
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}