# data "aws_iam_role" "ebs_iam_service_role" {
#   name = "AWSServiceRoleForElasticBeanstalk"
# }

module "vpc" {
  source               = "./modules/vpc"
  project          = var.project
  vpc_cidr             = var.vpc_cidr_block
  vpc_subnet_cidr      = var.vpc_subnet_block
}

# module "postgres-rds" {
#   source            = "./modules/postgres-rds"
#   project       = var.project
#   allocated_storage = "5"
#   database_name     = var.database_name
#   subnet_ids        = module.vpc.private_subnets_ids
#   vpc_id            = module.vpc.vpc_id
#   instance_class    = "db.t2.micro"
#   multi_az          = var.database_multi_az
# }

module "ecs" {
  source              = "./modules/ecs"
  application_name    = var.application_name
  container_port      = var.container_port
  project             = var.project
  acm_cert_domain     = var.acm_cert_domain
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  security_groups_ids = [
    module.vpc.security_groups_ids
  ]
  subnets_ids         = module.vpc.private_subnets_ids
  public_subnet_ids   = module.vpc.public_subnets_ids
  repository_name     = "${var.project}/${var.application_name}"
  image_tag           = var.image_tag
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  log_retention_in_days = var.log_retention_in_days
}