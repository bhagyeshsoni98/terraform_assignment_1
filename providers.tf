provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner   = "Bhagyesh Soni"
      Project = "Terraform Citadel Assignment"
    }
  }
}
