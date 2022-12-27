variable "rds_instance_name" {
  type        = string
  description = "RDS instance name"
}

variable "rds_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "RDS master user"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private Subnet ids for RDS instance creation"
}

variable "backend_sg_id" {
  type        = string
  description = "Security group for RDS instance"
}
