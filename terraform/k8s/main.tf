variable "eks_cluster_role_arn" {
  default = ""
}
variable "subnet_ids" {
  default = ""
}
resource "aws_eks_cluster" "localstack" {
  name     = "localstack-eks"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

variable "eks_node_role_arn" {
  default = ""
}
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.localstack.name
  node_group_name = "localstack-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}