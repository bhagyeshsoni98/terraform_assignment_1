module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  ami = var.ec2_attributes.ami
  instance_type = var.ec2_attributes.instance_type
  key_name = var.ec2_attributes.key_name
  user_data_filename = var.ec2_attributes.user_data_filename
  db_name = var.rds_attributes.db_name
  db_username = var.rds_attributes.db_username
  db_user_password = module.rds.db_password
  db_rds_endpoint = module.rds.rds_instance_endpoint
}

module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_attributes.name
  vpc_cidr_block = var.vpc_attributes.cidr_block
  public_subnet_count = var.vpc_attributes.public_subnet_count
  private_subnet_count = var.vpc_attributes.private_subnet_count
  target_group_instance_ids = module.ec2.frontent_instance_ids
}

module "rds" {
  source = "./modules/rds"
  rds_instance_name = var.rds_attributes.instance_name
  rds_instance_class = var.rds_attributes.instance_class
  db_username = var.rds_attributes.db_username
  private_subnet_ids = module.vpc.private_subnet_ids
  backend_sg_id = module.ec2.backend_sg_id
}