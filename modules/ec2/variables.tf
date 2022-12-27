variable "vpc_id" {
  type        = string
  description = "VPC id that will be used for EC2 and Security group creation"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet ids"
}

variable "ami" {
  type        = string
  default     = "ami-0574da719dca65348"
  description = "EC2 Image id"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Key name if already configured on AWS. Otherwise if null new key pair will be created and public key of that key pair can be extacted from output"
}

variable "user_data_filename" {
  type        = string
  description = "Name of user data tamplate file from root directory of this project"
}

variable "db_name" {
  type        = string
  sensitive   = true
  description = "Mysql DB name"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Mysql DB username"
}

variable "db_user_password" {
  type        = string
  sensitive   = true
  description = "Mysql DB password"
}

variable "db_rds_endpoint" {
  type        = string
  sensitive   = true
  description = "Mysql DB endpoint"
}

variable "frontend_sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    })
  )

  validation {
    condition     = length(var.frontend_sg_rules) != 0 ? contains(["ingress", "egress"], var.frontend_sg_rules[*].type) : true
    error_message = "type must be \"ingress\" or \"egress\"."
  }

  default = []

  description = "Custom Security group rules for frontend instances"
}

variable "backend_sg_rules" {
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    })
  )

  validation {
    condition     = length(var.backend_sg_rules) != 0 ? contains(["ingress", "egress"], var.backend_sg_rules[*].type) : true
    error_message = "type must be \"ingress\" or \"egress\"."
  }

  default = []

  description = "Custom Security group rules for backend instances"
}
