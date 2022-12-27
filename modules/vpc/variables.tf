variable "vpc_name" {
  type        = string
  default     = "my_custom_vpc"
  description = "VPC Name"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC Cidr block"
}

variable "public_subnet_count" {
  type        = number
  default     = 3
  description = "Number of public subnets"
}

variable "private_subnet_count" {
  type        = number
  default     = 3
  description = "Number of private subnets"
}

variable "target_group_instance_ids" {
  type        = list(string)
  description = "EC2 instance ids for elb target groups"
}
