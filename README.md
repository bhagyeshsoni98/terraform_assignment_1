# Terraform Assignment :

This terraform assignment is part of terraform learning from repo : https://github.com/infracloudio/citadel-internal/tree/master/modules/Terraform.

Two task are mention in the mentioned learning repo. This assignment combine both of the task into one.

## Tasks defined in learning repo :

  - ### Task 1 :
    ---
    Setup a WordPress application on apache web-server installed in EC2 instance via user_data template. Create and attach ELB to the EC2 instance for traffic routing and similarly create an RDS Mysql database with user credentials to configure the WordPress application. 

  - ### Task 2 :
    ---
    Find the latest stable version available for terraform at the time when you are performing this assignment, and configure it on your local system. Create below resources as per the required setup.
    1. **Divide your code in separate files/directories as per this format:**
         - Modules folder - which will contain the code for each of the resource we are going to create
         - provider.tf - provider and backend configuration
         - outputs.tf - should contain the outputs (information which we want the user to get back after each terraform run)
         - vars.tf - Should only contain the variable declarations
         - main.tf - which will contain the code to call a specific module
  
    2. **VPC and networking details**: Create VPC with 3 private and 3 public subnets. Create NAT gateway, internet gateway and route tables such that the instances in the public subnet should be able to access the internet directly through the internet gateway and anyone from outside should be able to access the instance in public subnet if security group allows. Resources in private subnet should not be accessible from outside of the VPC directly but at the same time resources within the private subnet should be able to access the internet via NAT gateway, ie for resources in private subnet, inbound connections from outside of VPC should not be allowed, but outbound connections from within the subnet should be allowed as we route them via NAT instance. Create all networking related components in one module.
         - For EC2 :
            - Inbound - allow port 22 access from specific IPs which are whitelisted. 
             - Outbound - rules - All allowed.
         - For RDS 
             - Inbound* - port 5432 (PostgreSQL) for SG that was created for EC2.
             - Outbound rules - All allowed.

    3. Create below resources with the help of their separate terraform modules. Create your own modules, don't use terraform modules from documentation / community.
         - RDS instance - PostgreSQL with minimum hardware (should be within free tier). RDS should be created within private subnets.
         - EC2 instance - Linux t2.micro instance should be in public subnet. Also, create a public / private key pair for authentication over SSH.
         -  VPC components - as stated in point 1.

---

### **Both of upper mentioned tasks are combined. So, have created modules of EC2, VPC and RDS. On frontend layer, deployed wordpress sample site using apache in public subnet and on backend layer, using RDS instance in private subnet. Access to RDS instance is only configured through frontend layer instances.**

> Directory Structure:
```bash
bhagyesh@BHAGYESH-SONI:~/citadel_assignment/terraform_assignment$ tree --dirsfirst
.
├── modules
│   ├── ec2
│   │   ├── key_pair.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   ├── security_groups.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── db_secrets.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   └── variables.tf
│   └── vpc
│       ├── elb_security_group.tf
│       ├── elb.tf
│       ├── internet_gateway.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── README.md
│       ├── route_tables.tf
│       ├── subnet.tf
│       └── variables.tf
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── terraform.tfvars
├── user_data.tpl
└── variables.tf

4 directories, 28 files
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name                                          | Source        | Version |
| --------------------------------------------- | ------------- | ------- |
| <a name="module_ec2"></a> [ec2](#module\_ec2) | ./modules/ec2 | n/a     |
| <a name="module_rds"></a> [rds](#module\_rds) | ./modules/rds | n/a     |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                           | Description                                        | Type  | Default | Required |
| ------------------------------------------------------------------------------ | -------------------------------------------------- | ----- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region)             | AWS Region in which infrastructure will be created | `any` | n/a     |   yes    |
| <a name="input_ec2_attributes"></a> [ec2\_attributes](#input\_ec2\_attributes) | Variables for ec2 module                           | `any` | n/a     |   yes    |
| <a name="input_rds_attributes"></a> [rds\_attributes](#input\_rds\_attributes) | Variables for rds module                           | `any` | n/a     |   yes    |
| <a name="input_vpc_attributes"></a> [vpc\_attributes](#input\_vpc\_attributes) | Variables for vpc module                           | `any` | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->