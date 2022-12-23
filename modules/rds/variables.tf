variable "rds_instance_name" {
  type = string
}

variable "rds_instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "backend_sg_id" {
  type = string
}