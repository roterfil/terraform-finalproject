module "vpc" {
  source = "./modules/vpc"

  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  az_1                  = var.az_1
  az_2                  = var.az_2

  lastname      = var.lastname
  engineer_name = var.engineer_name
  project_code  = var.project_code
  project_name  = var.project_name
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = var.vpc_cidr
  lastname      = var.lastname
  engineer_name = var.engineer_name
  project_code  = var.project_code
  project_name  = var.project_name
}

module "load_balancers" {
  source = "./modules/load_balancers"

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  alb_sg_id       = module.security_groups.alb_sg_id

  lastname      = var.lastname
  engineer_name = var.engineer_name
  project_code  = var.project_code
  project_name  = var.project_name
}

module "compute" {
  source = "./modules/compute"

  vpc_zone_identifier = module.vpc.private_subnets
  public_subnet_id    = module.vpc.public_subnets[0]

  bastion_sg_id   = module.security_groups.bastion_sg_id
  frontend_sg_id  = module.security_groups.frontend_sg_id
  backend_sg_id   = module.security_groups.backend_sg_id
  frontend_tg_arn = module.load_balancers.frontend_tg_arn
  backend_tg_arn  = module.load_balancers.backend_tg_arn

  frontend_userdata = templatefile("${path.module}/scripts/frontend_userdata.sh", {
    backend_dns = module.load_balancers.backend_dns
  })

  backend_userdata = file("${path.module}/scripts/backend_userdata.sh")

  lastname      = var.lastname
  engineer_name = var.engineer_name
  project_code  = var.project_code
  project_name  = var.project_name
}