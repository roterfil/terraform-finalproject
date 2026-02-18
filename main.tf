data "aws_availability_zones" "available" {
  state = "available"
}
locals {
  name_prefix = "${var.project_info["lastname"]}-${var.project_info["project_name"]}"
}

# NETWORKING MODULE
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
  name_prefix          = local.name_prefix
}

# SECURITY MODULE
module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr
  name_prefix = local.name_prefix
}

# LOAD BALANCER MODULE
module "load_balancers" {
  source          = "./modules/load_balancers"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  alb_sg_id       = module.security_groups.alb_sg_id
  name_prefix     = local.name_prefix
}

# COMPUTE MODULE
module "compute" {
  source = "./modules/compute"

  frontend_tg_arn     = module.load_balancers.frontend_tg_arn
  backend_tg_arn      = module.load_balancers.backend_tg_arn
  vpc_zone_identifier = module.vpc.private_subnets
  public_subnet_id    = module.vpc.public_subnets[0]
  bastion_sg_id       = module.security_groups.bastion_sg_id
  frontend_sg_id      = module.security_groups.frontend_sg_id
  backend_sg_id       = module.security_groups.backend_sg_id
  name_prefix         = local.name_prefix

  frontend_userdata = templatefile("${path.module}/scripts/frontend_userdata.sh", {
    backend_dns = module.load_balancers.backend_dns
  })
  backend_userdata = file("${path.module}/scripts/backend_userdata.sh")
}
