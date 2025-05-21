output "cluster_name" {
  value = "${var.app_name}-${random_id.cluster_suffix.hex}"
}

output "is_ready" {
  value = null_resource.cluster_ready.id
}