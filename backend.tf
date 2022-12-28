terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-custom"
    key            = "terraform.tfstate"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
    region         = "us-east-1"
  }
}
