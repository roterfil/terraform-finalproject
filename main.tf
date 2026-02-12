################################################
# 1. DYNAMIC DATA SOURCES
################################################
# Fetches the list of available AZs in the region (Joel's Feedback)
data "aws_availability_zones" "available" {
  state = "available"
}

################################################
# 2. CENTRALIZED LOCALS
################################################
locals {
  # Standardized Prefix: {Lastname}-FinalProject
  name_prefix = "${var.project_info["lastname"]}-${var.project_info["project_name"]}"

  # Reusable Tags (No need to repeat these in every module)
  common_tags = {
    Engineer    = var.project_info["engineer_name"]
    ProjectCode = var.project_info["project_code"]
  }
}

################################################
# 3. NETWORKING MODULE (VPC, Subnets, IGW, NAT)
################################################
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # Passes the dynamic AZ list from the data source above
  availability_zones = data.aws_availability_zones.available.names

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

################################################
# 4. SECURITY MODULE (Security Groups)
################################################
module "security_groups" {
  source   = "./modules/security_groups"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

################################################
# 5. LOAD BALANCER MODULE (ALB & NLB)
################################################
module "load_balancers" {
  source          = "./modules/load_balancers"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  alb_sg_id       = module.security_groups.alb_sg_id

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# COMPUTE MODULE (Bastion, ASGs, Scaling)
module "compute" {
  source = "./modules/compute"

  # Target Groups for ASG integration
  frontend_tg_arn = module.load_balancers.frontend_tg_arn
  backend_tg_arn  = module.load_balancers.backend_tg_arn

  # Networking placement
  vpc_zone_identifier = module.vpc.private_subnets   # ASGs go in Private Subnets
  public_subnet_id    = module.vpc.public_subnets[0] # Bastion goes in 1st Public Subnet

  # Security Assignment
  bastion_sg_id  = module.security_groups.bastion_sg_id
  frontend_sg_id = module.security_groups.frontend_sg_id
  backend_sg_id  = module.security_groups.backend_sg_id

  # Naming and Tagging
  name_prefix = local.name_prefix
  common_tags = local.common_tags

  # Userdata Injection
  # Injects the Network Load Balancer DNS into the Frontend shell script
  frontend_userdata = templatefile("${path.module}/scripts/frontend_userdata.sh", {
    backend_dns = module.load_balancers.backend_dns
  })

  backend_userdata = file("${path.module}/scripts/backend_userdata.sh")
}
