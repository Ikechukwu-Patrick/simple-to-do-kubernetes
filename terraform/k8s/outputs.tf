output "cluster_name" {
  value = aws_eks_cluster.localstack.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.localstack.endpoint
}

output "cluster_certificate" {
  value = aws_eks_cluster.localstack.certificate_authority[0].data
}