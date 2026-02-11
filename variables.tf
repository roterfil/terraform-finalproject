variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "project_info" {
  type = map(string)
  description = "Contains lastname, engineer_name, project_code, and project_name"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}