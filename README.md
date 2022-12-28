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

---

## **Terraform Plan :**

```bash
bhagyesh@BHAGYESH-SONI:~/citadel_assignment/terraform_assignment$ terraform plan -lock=false
module.vpc.data.aws_availability_zones.available: Reading...
module.vpc.data.aws_availability_zones.available: Read complete after 2s [id=us-east-1]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # module.ec2.data.template_file.user_data[0] will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "user_data" {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<-EOT
            #!/bin/bash
            
            # Editing /etc/needrestart/needrestart.conf to restart services that needs to be restarted after apt upgrade without waiting for user approval.
            sed -i 's/#\$nrconf{restart} = '\''i'\'';/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf
            
            # varaible will be populated by terraform template
            export db_username=${db_username}
            export db_user_password=${db_user_password}
            export db_name=${db_name}
            export db_rds_endpoint=${db_rds_endpoint}
            export db_host=$(echo $db_rds_endpoint | cut -d ':' -f 1)
            export admin_email='admin@abcd.com'
            export instance_cnt=${instance_count}
            export title="Sample Wordpress Site from Instance-$instance_cnt"
            export wordpress_path="/var/www/html/wordpress$instance_cnt"
            
            # update packages to latest
            apt update -y
            apt upgrade -y
            
            # install LAMP server
            apt install -y apache2
            apt install -y php php-{pear,cgi,common,curl,mbstring,gd,mysql,bcmath,json,xml,intl,zip,imap,imagick}
            apt install -y mysql-server
            
            mysql -u $db_username -h $db_host --password=$db_user_password -e "create database $db_name"
            
            # start apache server and enable it to run on startup
            systemctl enable --now apache2
            
            mkdir $wordpress_path
            
            # install wordpress cli and setting up wordpress
            curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
            chmod +x wp-cli.phar
            mv wp-cli.phar /usr/local/bin/wp
            wp core download --path=$wordpress_path --allow-root
            wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_rds_endpoint --path=$wordpress_path --allow-root --extra-php <<PHP
            define( 'FS_METHOD', 'direct' );
            define('WP_MEMORY_LIMIT', '128M');
            PHP
            wp core install --url=url --title=$title --admin_name=$db_username --admin_email=$admin_email --admin_password=$db_user_password --path=$wordpress_path --skip-email --allow-root
            
            
            # enable .htaccess files in apache config using sed command
            sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
            a2enmod rewrite
            
            # restart apache
            systemctl restart apache2
        EOT
      + vars     = {
          + "db_name"          = (sensitive value)
          + "db_rds_endpoint"  = (sensitive value)
          + "db_user_password" = (sensitive value)
          + "db_username"      = (sensitive value)
          + "instance_count"   = "0"
        }
    }

  # module.ec2.data.template_file.user_data[1] will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "user_data" {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<-EOT
            #!/bin/bash
            
            # Editing /etc/needrestart/needrestart.conf to restart services that needs to be restarted after apt upgrade without waiting for user approval.
            sed -i 's/#\$nrconf{restart} = '\''i'\'';/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf
            
            # varaible will be populated by terraform template
            export db_username=${db_username}
            export db_user_password=${db_user_password}
            export db_name=${db_name}
            export db_rds_endpoint=${db_rds_endpoint}
            export db_host=$(echo $db_rds_endpoint | cut -d ':' -f 1)
            export admin_email='admin@abcd.com'
            export instance_cnt=${instance_count}
            export title="Sample Wordpress Site from Instance-$instance_cnt"
            export wordpress_path="/var/www/html/wordpress$instance_cnt"
            
            # update packages to latest
            apt update -y
            apt upgrade -y
            
            # install LAMP server
            apt install -y apache2
            apt install -y php php-{pear,cgi,common,curl,mbstring,gd,mysql,bcmath,json,xml,intl,zip,imap,imagick}
            apt install -y mysql-server
            
            mysql -u $db_username -h $db_host --password=$db_user_password -e "create database $db_name"
            
            # start apache server and enable it to run on startup
            systemctl enable --now apache2
            
            mkdir $wordpress_path
            
            # install wordpress cli and setting up wordpress
            curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
            chmod +x wp-cli.phar
            mv wp-cli.phar /usr/local/bin/wp
            wp core download --path=$wordpress_path --allow-root
            wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_rds_endpoint --path=$wordpress_path --allow-root --extra-php <<PHP
            define( 'FS_METHOD', 'direct' );
            define('WP_MEMORY_LIMIT', '128M');
            PHP
            wp core install --url=url --title=$title --admin_name=$db_username --admin_email=$admin_email --admin_password=$db_user_password --path=$wordpress_path --skip-email --allow-root
            
            
            # enable .htaccess files in apache config using sed command
            sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
            a2enmod rewrite
            
            # restart apache
            systemctl restart apache2
        EOT
      + vars     = {
          + "db_name"          = (sensitive value)
          + "db_rds_endpoint"  = (sensitive value)
          + "db_user_password" = (sensitive value)
          + "db_username"      = (sensitive value)
          + "instance_count"   = "1"
        }
    }

  # module.ec2.data.template_file.user_data[2] will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "user_data" {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<-EOT
            #!/bin/bash
            
            # Editing /etc/needrestart/needrestart.conf to restart services that needs to be restarted after apt upgrade without waiting for user approval.
            sed -i 's/#\$nrconf{restart} = '\''i'\'';/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf
            
            # varaible will be populated by terraform template
            export db_username=${db_username}
            export db_user_password=${db_user_password}
            export db_name=${db_name}
            export db_rds_endpoint=${db_rds_endpoint}
            export db_host=$(echo $db_rds_endpoint | cut -d ':' -f 1)
            export admin_email='admin@abcd.com'
            export instance_cnt=${instance_count}
            export title="Sample Wordpress Site from Instance-$instance_cnt"
            export wordpress_path="/var/www/html/wordpress$instance_cnt"
            
            # update packages to latest
            apt update -y
            apt upgrade -y
            
            # install LAMP server
            apt install -y apache2
            apt install -y php php-{pear,cgi,common,curl,mbstring,gd,mysql,bcmath,json,xml,intl,zip,imap,imagick}
            apt install -y mysql-server
            
            mysql -u $db_username -h $db_host --password=$db_user_password -e "create database $db_name"
            
            # start apache server and enable it to run on startup
            systemctl enable --now apache2
            
            mkdir $wordpress_path
            
            # install wordpress cli and setting up wordpress
            curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
            chmod +x wp-cli.phar
            mv wp-cli.phar /usr/local/bin/wp
            wp core download --path=$wordpress_path --allow-root
            wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_rds_endpoint --path=$wordpress_path --allow-root --extra-php <<PHP
            define( 'FS_METHOD', 'direct' );
            define('WP_MEMORY_LIMIT', '128M');
            PHP
            wp core install --url=url --title=$title --admin_name=$db_username --admin_email=$admin_email --admin_password=$db_user_password --path=$wordpress_path --skip-email --allow-root
            
            
            # enable .htaccess files in apache config using sed command
            sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
            a2enmod rewrite
            
            # restart apache
            systemctl restart apache2
        EOT
      + vars     = {
          + "db_name"          = (sensitive value)
          + "db_rds_endpoint"  = (sensitive value)
          + "db_user_password" = (sensitive value)
          + "db_username"      = (sensitive value)
          + "instance_count"   = "2"
        }
    }

  # module.ec2.aws_instance.frontend[0] will be created
  + resource "aws_instance" "frontend" {
      + ami                                  = "ami-0574da719dca65348"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "pubkey"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "frontend_instance_0"
        }
      + tags_all                             = {
          + "Name"    = "frontend_instance_0"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + maintenance_options {
          + auto_recovery = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + private_dns_name_options {
          + enable_resource_name_dns_a_record    = (known after apply)
          + enable_resource_name_dns_aaaa_record = (known after apply)
          + hostname_type                        = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.ec2.aws_instance.frontend[1] will be created
  + resource "aws_instance" "frontend" {
      + ami                                  = "ami-0574da719dca65348"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "pubkey"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "frontend_instance_1"
        }
      + tags_all                             = {
          + "Name"    = "frontend_instance_1"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + maintenance_options {
          + auto_recovery = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + private_dns_name_options {
          + enable_resource_name_dns_a_record    = (known after apply)
          + enable_resource_name_dns_aaaa_record = (known after apply)
          + hostname_type                        = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.ec2.aws_instance.frontend[2] will be created
  + resource "aws_instance" "frontend" {
      + ami                                  = "ami-0574da719dca65348"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "pubkey"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "frontend_instance_2"
        }
      + tags_all                             = {
          + "Name"    = "frontend_instance_2"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + maintenance_options {
          + auto_recovery = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
          + instance_metadata_tags      = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + private_dns_name_options {
          + enable_resource_name_dns_a_record    = (known after apply)
          + enable_resource_name_dns_aaaa_record = (known after apply)
          + hostname_type                        = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # module.ec2.aws_security_group.backend_sg will be created
  + resource "aws_security_group" "backend_sg" {
      + arn                    = (known after apply)
      + description            = "Security Group for db instances"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "backend_sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "backend-instance-sg"
        }
      + tags_all               = {
          + "Name"    = "backend-instance-sg"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                 = (known after apply)
    }

  # module.ec2.aws_security_group.frontend_sg will be created
  + resource "aws_security_group" "frontend_sg" {
      + arn                    = (known after apply)
      + description            = "SG for frontend instances"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "frontend_sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "frontend-instance-sg"
        }
      + tags_all               = {
          + "Name"    = "frontend-instance-sg"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                 = (known after apply)
    }

  # module.ec2.aws_security_group_rule.backend_sg_allow_all_outbound_traffic will be created
  + resource "aws_security_group_rule" "backend_sg_allow_all_outbound_traffic" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # module.ec2.aws_security_group_rule.db_ingress_frontend will be created
  + resource "aws_security_group_rule" "db_ingress_frontend" {
      + description              = "Allow frontend instance traffic for DB instance"
      + from_port                = 3306
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 3306
      + type                     = "ingress"
    }

  # module.ec2.aws_security_group_rule.frontend_ingress_db will be created
  + resource "aws_security_group_rule" "frontend_ingress_db" {
      + description              = "Allow DB instance traffic for frontend"
      + from_port                = 3306
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 3306
      + type                     = "ingress"
    }

  # module.ec2.aws_security_group_rule.frontend_ingress_http will be created
  + resource "aws_security_group_rule" "frontend_ingress_http" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "HTTP for frontend"
      + from_port                = 80
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 80
      + type                     = "ingress"
    }

  # module.ec2.aws_security_group_rule.frontend_ingress_https will be created
  + resource "aws_security_group_rule" "frontend_ingress_https" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "HTTPS for frontend"
      + from_port                = 443
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "ingress"
    }

  # module.ec2.aws_security_group_rule.frontend_ingress_ssh will be created
  + resource "aws_security_group_rule" "frontend_ingress_ssh" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + description              = "SSH for frontend"
      + from_port                = 22
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 22
      + type                     = "ingress"
    }

  # module.ec2.aws_security_group_rule.frontend_sg_allow_all_outbound_traffic will be created
  + resource "aws_security_group_rule" "frontend_sg_allow_all_outbound_traffic" {
      + cidr_blocks              = [
          + "0.0.0.0/0",
        ]
      + from_port                = 0
      + id                       = (known after apply)
      + protocol                 = "-1"
      + security_group_id        = (known after apply)
      + security_group_rule_id   = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 0
      + type                     = "egress"
    }

  # module.rds.aws_db_instance.mysql_rds_instance will be created
  + resource "aws_db_instance" "mysql_rds_instance" {
      + address                               = (known after apply)
      + allocated_storage                     = 10
      + apply_immediately                     = false
      + arn                                   = (known after apply)
      + auto_minor_version_upgrade            = true
      + availability_zone                     = (known after apply)
      + backup_retention_period               = (known after apply)
      + backup_window                         = (known after apply)
      + ca_cert_identifier                    = (known after apply)
      + character_set_name                    = (known after apply)
      + copy_tags_to_snapshot                 = false
      + db_name                               = (known after apply)
      + db_subnet_group_name                  = "aws_db_subnet_group"
      + delete_automated_backups              = true
      + endpoint                              = (known after apply)
      + engine                                = "mysql"
      + engine_version                        = (known after apply)
      + engine_version_actual                 = (known after apply)
      + hosted_zone_id                        = (known after apply)
      + id                                    = (known after apply)
      + identifier                            = "wpdb"
      + identifier_prefix                     = (known after apply)
      + instance_class                        = "db.t3.micro"
      + iops                                  = (known after apply)
      + kms_key_id                            = (known after apply)
      + latest_restorable_time                = (known after apply)
      + license_model                         = (known after apply)
      + maintenance_window                    = (known after apply)
      + monitoring_interval                   = 0
      + monitoring_role_arn                   = (known after apply)
      + multi_az                              = (known after apply)
      + name                                  = (known after apply)
      + nchar_character_set_name              = (known after apply)
      + network_type                          = (known after apply)
      + option_group_name                     = (known after apply)
      + parameter_group_name                  = (known after apply)
      + password                              = (sensitive value)
      + performance_insights_enabled          = false
      + performance_insights_kms_key_id       = (known after apply)
      + performance_insights_retention_period = (known after apply)
      + port                                  = (known after apply)
      + publicly_accessible                   = false
      + replica_mode                          = (known after apply)
      + replicas                              = (known after apply)
      + resource_id                           = (known after apply)
      + skip_final_snapshot                   = true
      + snapshot_identifier                   = (known after apply)
      + status                                = (known after apply)
      + storage_throughput                    = (known after apply)
      + storage_type                          = (known after apply)
      + tags                                  = {
          + "CreatedBy" = "Bhagyesh Soni"
          + "Name"      = "Terraform citadel module assignment"
        }
      + tags_all                              = {
          + "CreatedBy" = "Bhagyesh Soni"
          + "Name"      = "Terraform citadel module assignment"
          + "Owner"     = "Bhagyesh Soni"
          + "Project"   = "Terraform Citadel Assignment"
        }
      + timezone                              = (known after apply)
      + username                              = (sensitive value)
      + vpc_security_group_ids                = (known after apply)
    }

  # module.rds.aws_db_subnet_group.db_subnet_group will be created
  + resource "aws_db_subnet_group" "db_subnet_group" {
      + arn                     = (known after apply)
      + description             = "Managed by Terraform"
      + id                      = (known after apply)
      + name                    = "aws_db_subnet_group"
      + name_prefix             = (known after apply)
      + subnet_ids              = (known after apply)
      + supported_network_types = (known after apply)
      + tags                    = {
          + "Name" = "My DB subnet group"
        }
      + tags_all                = {
          + "Name"    = "My DB subnet group"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
    }

  # module.rds.aws_secretsmanager_secret.db_secret will be created
  + resource "aws_secretsmanager_secret" "db_secret" {
      + arn                            = (known after apply)
      + force_overwrite_replica_secret = false
      + id                             = (known after apply)
      + name                           = "db_password"
      + name_prefix                    = (known after apply)
      + policy                         = (known after apply)
      + recovery_window_in_days        = 0
      + rotation_enabled               = (known after apply)
      + rotation_lambda_arn            = (known after apply)
      + tags_all                       = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }

      + replica {
          + kms_key_id         = (known after apply)
          + last_accessed_date = (known after apply)
          + region             = (known after apply)
          + status             = (known after apply)
          + status_message     = (known after apply)
        }

      + rotation_rules {
          + automatically_after_days = (known after apply)
        }
    }

  # module.rds.aws_secretsmanager_secret_version.db_pass will be created
  + resource "aws_secretsmanager_secret_version" "db_pass" {
      + arn            = (known after apply)
      + id             = (known after apply)
      + secret_id      = (known after apply)
      + secret_string  = (sensitive value)
      + version_id     = (known after apply)
      + version_stages = (known after apply)
    }

  # module.rds.random_password.db_password will be created
  + resource "random_password" "db_password" {
      + bcrypt_hash      = (sensitive value)
      + id               = (known after apply)
      + length           = 16
      + lower            = true
      + min_lower        = 1
      + min_numeric      = 1
      + min_special      = 2
      + min_upper        = 1
      + number           = true
      + numeric          = true
      + override_special = "_"
      + result           = (sensitive value)
      + special          = true
      + upper            = true
    }

  # module.vpc.aws_internet_gateway.my_igw will be created
  + resource "aws_internet_gateway" "my_igw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "my_custom_igw"
        }
      + tags_all = {
          + "Name"    = "my_custom_igw"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id   = (known after apply)
    }

  # module.vpc.aws_lb.frontend_lb will be created
  + resource "aws_lb" "frontend_lb" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + desync_mitigation_mode     = "defensive"
      + dns_name                   = (known after apply)
      + drop_invalid_header_fields = false
      + enable_deletion_protection = false
      + enable_http2               = true
      + enable_waf_fail_open       = false
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "frontend-lb"
      + preserve_host_header       = false
      + security_groups            = (known after apply)
      + subnets                    = (known after apply)
      + tags_all                   = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # module.vpc.aws_lb_listener.frontend_lb_http_listener will be created
  + resource "aws_lb_listener" "frontend_lb_http_listener" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)
      + tags_all          = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.vpc.aws_lb_listener_rule.frontend_lb_http_listener_rule[0] will be created
  + resource "aws_lb_listener_rule" "frontend_lb_http_listener_rule" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = (known after apply)
      + tags_all     = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {

          + path_pattern {
              + values = [
                  + "/wordpress0*",
                ]
            }
        }
    }

  # module.vpc.aws_lb_listener_rule.frontend_lb_http_listener_rule[1] will be created
  + resource "aws_lb_listener_rule" "frontend_lb_http_listener_rule" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = (known after apply)
      + tags_all     = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {

          + path_pattern {
              + values = [
                  + "/wordpress1*",
                ]
            }
        }
    }

  # module.vpc.aws_lb_listener_rule.frontend_lb_http_listener_rule[2] will be created
  + resource "aws_lb_listener_rule" "frontend_lb_http_listener_rule" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = (known after apply)
      + tags_all     = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {

          + path_pattern {
              + values = [
                  + "/wordpress2*",
                ]
            }
        }
    }

  # module.vpc.aws_lb_target_group.frontend_tg[0] will be created
  + resource "aws_lb_target_group" "frontend_tg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "frontend-tg-0"
      + port                               = 80
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = (known after apply)
          + healthy_threshold   = (known after apply)
          + interval            = (known after apply)
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = (known after apply)
          + protocol            = (known after apply)
          + timeout             = (known after apply)
          + unhealthy_threshold = (known after apply)
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }

      + target_failover {
          + on_deregistration = (known after apply)
          + on_unhealthy      = (known after apply)
        }
    }

  # module.vpc.aws_lb_target_group.frontend_tg[1] will be created
  + resource "aws_lb_target_group" "frontend_tg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "frontend-tg-1"
      + port                               = 80
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = (known after apply)
          + healthy_threshold   = (known after apply)
          + interval            = (known after apply)
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = (known after apply)
          + protocol            = (known after apply)
          + timeout             = (known after apply)
          + unhealthy_threshold = (known after apply)
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }

      + target_failover {
          + on_deregistration = (known after apply)
          + on_unhealthy      = (known after apply)
        }
    }

  # module.vpc.aws_lb_target_group.frontend_tg[2] will be created
  + resource "aws_lb_target_group" "frontend_tg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "frontend-tg-2"
      + port                               = 80
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = (known after apply)
          + healthy_threshold   = (known after apply)
          + interval            = (known after apply)
          + matcher             = (known after apply)
          + path                = (known after apply)
          + port                = (known after apply)
          + protocol            = (known after apply)
          + timeout             = (known after apply)
          + unhealthy_threshold = (known after apply)
        }

      + stickiness {
          + cookie_duration = (known after apply)
          + cookie_name     = (known after apply)
          + enabled         = (known after apply)
          + type            = (known after apply)
        }

      + target_failover {
          + on_deregistration = (known after apply)
          + on_unhealthy      = (known after apply)
        }
    }

  # module.vpc.aws_lb_target_group_attachment.frontend_tg_attachment[0] will be created
  + resource "aws_lb_target_group_attachment" "frontend_tg_attachment" {
      + id               = (known after apply)
      + port             = 80
      + target_group_arn = (known after apply)
      + target_id        = (known after apply)
    }

  # module.vpc.aws_lb_target_group_attachment.frontend_tg_attachment[1] will be created
  + resource "aws_lb_target_group_attachment" "frontend_tg_attachment" {
      + id               = (known after apply)
      + port             = 80
      + target_group_arn = (known after apply)
      + target_id        = (known after apply)
    }

  # module.vpc.aws_lb_target_group_attachment.frontend_tg_attachment[2] will be created
  + resource "aws_lb_target_group_attachment" "frontend_tg_attachment" {
      + id               = (known after apply)
      + port             = 80
      + target_group_arn = (known after apply)
      + target_id        = (known after apply)
    }

  # module.vpc.aws_route_table.public_route_table will be created
  + resource "aws_route_table" "public_route_table" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + core_network_arn           = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = (known after apply)
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
      + tags_all         = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id           = (known after apply)
    }

  # module.vpc.aws_route_table_association.public_route_table_association[0] will be created
  + resource "aws_route_table_association" "public_route_table_association" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public_route_table_association[1] will be created
  + resource "aws_route_table_association" "public_route_table_association" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_route_table_association.public_route_table_association[2] will be created
  + resource "aws_route_table_association" "public_route_table_association" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # module.vpc.aws_security_group.frontend_lb_sg will be created
  + resource "aws_security_group" "frontend_lb_sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Allow outbound traffic on port 80 for the world"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "Allow inboud traffic on port 80 for the world"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
        ]
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = {
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                 = (known after apply)
    }

  # module.vpc.aws_subnet.private_subnet[0] will be created
  + resource "aws_subnet" "private_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.96.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "private-subnet-0"
        }
      + tags_all                                       = {
          + "Name"    = "private-subnet-0"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private_subnet[1] will be created
  + resource "aws_subnet" "private_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.128.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "private-subnet-1"
        }
      + tags_all                                       = {
          + "Name"    = "private-subnet-1"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.private_subnet[2] will be created
  + resource "aws_subnet" "private_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.160.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "private-subnet-2"
        }
      + tags_all                                       = {
          + "Name"    = "private-subnet-2"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public_subnet[0] will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.0.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "public-subnet-0"
        }
      + tags_all                                       = {
          + "Name"    = "public-subnet-0"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public_subnet[1] will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.32.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "public-subnet-1"
        }
      + tags_all                                       = {
          + "Name"    = "public-subnet-1"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_subnet.public_subnet[2] will be created
  + resource "aws_subnet" "public_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.64.0/19"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = true
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "public-subnet-2"
        }
      + tags_all                                       = {
          + "Name"    = "public-subnet-2"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
      + vpc_id                                         = (known after apply)
    }

  # module.vpc.aws_vpc.my_vpc will be created
  + resource "aws_vpc" "my_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_classiclink                   = (known after apply)
      + enable_classiclink_dns_support       = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "my_custom_vpc"
        }
      + tags_all                             = {
          + "Name"    = "my_custom_vpc"
          + "Owner"   = "Bhagyesh Soni"
          + "Project" = "Terraform Citadel Assignment"
        }
    }

Plan: 41 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```