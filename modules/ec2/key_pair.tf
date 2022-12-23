locals {
  generate_key_pair = var.key_name == null ? 1 : 0
}

resource "tls_private_key" "generated_private_key" {
  count     = local.generate_key_pair
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_pair" {
  count     = local.generate_key_pair
  key_name   = "generated_key_pair"
  public_key = one(tls_private_key.generated_private_key[*].public_key_openssh)
}
