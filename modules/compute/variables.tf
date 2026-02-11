variable "vpc_zone_identifier" { type = list(string) }
variable "public_subnet_id" {}
variable "bastion_sg_id" {}
variable "frontend_sg_id" {}
variable "backend_sg_id" {}
variable "frontend_tg_arn" {}
variable "backend_tg_arn" {}
variable "frontend_userdata" {}
variable "backend_userdata" {}
variable "lastname" {}
variable "engineer_name" {}
variable "project_code" {}
variable "project_name" {}