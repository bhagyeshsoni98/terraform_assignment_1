<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.generated_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.backend_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.frontend_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.backend_sg_allow_all_outbound_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.backend_sg_rules](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.db_ingress_frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_ingress_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_ingress_http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_ingress_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_ingress_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_sg_allow_all_outbound_traffic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.frontend_sg_custom_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [tls_private_key.generated_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [template_file.user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | EC2 Image id | `string` | `"ami-0574da719dca65348"` | no |
| <a name="input_backend_sg_rules"></a> [backend\_sg\_rules](#input\_backend\_sg\_rules) | Custom Security group rules for backend instances | <pre>list(object({<br>    type        = string<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Mysql DB name | `string` | n/a | yes |
| <a name="input_db_rds_endpoint"></a> [db\_rds\_endpoint](#input\_db\_rds\_endpoint) | Mysql DB endpoint | `string` | n/a | yes |
| <a name="input_db_user_password"></a> [db\_user\_password](#input\_db\_user\_password) | Mysql DB password | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Mysql DB username | `string` | n/a | yes |
| <a name="input_frontend_sg_rules"></a> [frontend\_sg\_rules](#input\_frontend\_sg\_rules) | Custom Security group rules for frontend instances | <pre>list(object({<br>    type        = string<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>    cidr_blocks = list(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t2.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name if already configured on AWS. Otherwise if null new key pair will be created and public key of that key pair can be extacted from output | `string` | `null` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet ids | `list(string)` | n/a | yes |
| <a name="input_user_data_filename"></a> [user\_data\_filename](#input\_user\_data\_filename) | Name of user data tamplate file from root directory of this project | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id that will be used for EC2 and Security group creation | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_sg_id"></a> [backend\_sg\_id](#output\_backend\_sg\_id) | Backend security group ids |
| <a name="output_frontent_instance_ids"></a> [frontent\_instance\_ids](#output\_frontent\_instance\_ids) | Frontend instance's ids |
| <a name="output_generated_pvt_key"></a> [generated\_pvt\_key](#output\_generated\_pvt\_key) | Public key of newly generated key pair to access frontend EC2 instances |
<!-- END_TF_DOCS -->