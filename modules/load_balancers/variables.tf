variable "vpc_id" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "alb_sg_id" { type = string }

variable "name_prefix" { type = string }
variable "common_tags" { type = map(string) }
