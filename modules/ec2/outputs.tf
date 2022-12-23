output "generated_pvt_key" {
  value = one(tls_private_key.generated_private_key[*].private_key_pem)
  sensitive = true
}

output "frontent_instance_ids" {
  value = aws_instance.frontend[*].id
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}