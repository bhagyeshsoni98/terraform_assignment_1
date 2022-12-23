resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "aws_db_subnet_group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "postgres_rds_instance" {
  identifier             = var.rds_instance_name
  allocated_storage      = 10
  engine                 = "mysql"
  username               = var.db_username
  password               = random_password.db_password.result
  instance_class         = var.rds_instance_class
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = toset([var.backend_sg_id])
  skip_final_snapshot    = true

  tags = {
    "Name"      = "Terraform citadel module assignment"
    "CreatedBy" = "Bhagyesh Soni"
  }
}
