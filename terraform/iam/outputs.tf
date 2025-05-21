output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}