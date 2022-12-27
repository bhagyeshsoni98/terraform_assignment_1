output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "VPC id"
}

output "public_subnet_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "Public subnet ids"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "Private subnet ids"
}
