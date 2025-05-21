output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}