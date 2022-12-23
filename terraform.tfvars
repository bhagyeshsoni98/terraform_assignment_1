aws_region = "us-east-1"

ec2_attributes = {
  ami                = "ami-0574da719dca65348"
  instance_type      = "t2.micro"
  key_name           = "pubkey"
  user_data_filename = "user_data.tpl"
}

vpc_attributes = {
  name                 = "my_custom_vpc"
  cidr_block           = "10.0.0.0/16"
  public_subnet_count  = 3
  private_subnet_count = 3
}

rds_attributes = {
  instance_name = "wpdb"
  instance_class = "db.t3.micro"
  db_name = "wbpd"
  db_username = "admin"
}