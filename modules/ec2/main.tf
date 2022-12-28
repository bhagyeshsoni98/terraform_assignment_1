data "template_file" "user_data" {
  count    = length(var.public_subnet_ids)
  template = file("${path.root}/${var.user_data_filename}")
  vars = {
    db_username      = var.db_username
    db_user_password = var.db_user_password
    db_name          = join("", [var.db_name, count.index])
    db_rds_endpoint  = var.db_rds_endpoint
    instance_count   = "${count.index}"
  }
}

resource "aws_instance" "frontend" {
  count                       = length(var.public_subnet_ids)
  ami                         = var.ami
  instance_type               = var.instance_type
  associate_public_ip_address = true
  key_name                    = var.key_name == null ? one(aws_key_pair.generated_key_pair[*].key_name) : var.key_name
  vpc_security_group_ids      = toset([aws_security_group.frontend_sg.id])
  subnet_id                   = var.public_subnet_ids[count.index]
  user_data                   = data.template_file.user_data[count.index].rendered


  tags = {
    Name = "frontend_instance_${count.index}"
  }
}
