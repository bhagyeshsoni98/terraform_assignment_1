variable "aws_region" {
  description = "AWS Region in which infrastructure will be created"
}

variable "ec2_attributes" {
  description = "Variables for ec2 module"
}

variable "vpc_attributes" {
  description = "Variables for vpc module"
}

variable "rds_attributes" {
  description = "Variables for rds module"
}
