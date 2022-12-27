output "generated_pvt_key" {
  value       = one(tls_private_key.generated_private_key[*].private_key_pem)
  sensitive   = true
  description = "Private key of newly generated key pair to access frontend EC2 instances"
}

output "frontent_instance_ids" {
  value       = aws_instance.frontend[*].id
  description = "Frontend instance's ids"
}

output "backend_sg_id" {
  value       = aws_security_group.backend_sg.id
  description = "Backend security group ids"
}
