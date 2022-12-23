variable "vpc_name" {
  type  = string
  default = "my_custom_vpc"
}

variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_count" {
  type = number
  default = 3
}

variable "private_subnet_count" {
  type = number
  default = 3
}

variable "target_group_instance_ids" {
  type = list(string)
}