variable "vpc_id" {
  type = string  
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "ami" {
  type    = string
  default = "ami-0574da719dca65348"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "user_data_filename" {
  type = string
}

variable "db_name" {
  type = string
  sensitive = true
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_user_password" {
  type = string
  sensitive = true
}

variable "db_rds_endpoint" {
  type = string
  sensitive = true
}

variable "frontend_sg_rules" {
  type = list(object({
                type = string
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              })
          )
  
  validation {
    condition = length(var.frontend_sg_rules) != 0 ? contains(["ingress", "egress"], var.frontend_sg_rules[*].type) : true
    error_message = "type must be \"ingress\" or \"egress\"."
  }

  default = []
}

variable "backend_sg_rules" {
  type = list(object({
                type = string
                from_port = number
                to_port = number
                protocol = string
                cidr_blocks = list(string)
              })
          )
  
  validation {
    condition = length(var.backend_sg_rules) != 0 ? contains(["ingress", "egress"], var.backend_sg_rules[*].type) : true
    error_message = "type must be \"ingress\" or \"egress\"."
  }

  default = []
}