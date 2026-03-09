module "networking" {
  source = "./modules/networking"

  # Naming variables
  project     = var.project
  environment = var.environment

  # Network variables
  vpc_cidr         = var.vpc_cidr
  azs              = var.azs
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets
}

module "security" {
  source = "./modules/security"

  project     = var.project
  environment = var.environment
  vpc_id      = module.networking.vpc_id
}

module "iam" {
  source = "./modules/iam"

  project     = var.project
  environment = var.environment
}

module "database" {
  source = "./modules/database"
  project     = var.project
  environment = var.environment

  # Dynamic inputs from other modules
  database_subnet_ids  = module.networking.database_subnet_ids
  db_security_group_id = module.security.db_sg_id
}

module "cache" {
  source = "./modules/cache"

  project                 = var.project
  environment             = var.environment
  database_subnet_ids     = module.networking.database_subnet_ids
  cache_security_group_id = module.security.cache_sg_id
}

module "alb" {
  source = "./modules/alb"

  project               = var.project
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.security.alb_sg_id
  logs_bucket_id        = module.storage.logs_bucket_id
}

module "compute" {
  source = "./modules/compute"

  project                   = var.project
  environment               = var.environment
  
  private_subnet_ids        = module.networking.private_subnet_ids
  app_sg_id                 = module.security.app_sg_id
  target_group_arn          = module.alb.target_group_arn
  app_instance_profile_name = module.iam.app_instance_profile_name
  
  # Backend Connections
  db_endpoint               = module.database.db_endpoint
  db_secret_arn             = module.database.db_secret_arn
  redis_endpoint            = module.cache.redis_primary_endpoint
}

module "storage" {
  source = "./modules/storage"
  project     = var.project
  environment = var.environment
}

module "cdn" {
  source = "./modules/cdn"

  project     = var.project
  environment = var.environment

  # Wiring up the exact outputs from the storage module
  static_assets_bucket_id                   = module.storage.static_assets_bucket_id
  static_assets_bucket_regional_domain_name = module.storage.static_assets_bucket_regional_domain_name
  logs_bucket_domain_name                   = module.storage.logs_bucket_domain_name
  oai_cloudfront_access_identity_path       = module.storage.oai_cloudfront_access_identity_path
}

module "monitoring" {
  source = "./modules/monitoring"

  project     = var.project
  environment = var.environment
  
  # Wiring up all the components
  alert_email            = var.alert_email
  vpc_id                 = module.networking.vpc_id
  alb_arn_suffix         = module.alb.alb_arn_suffix
  asg_name               = module.compute.asg_name
  rds_db_identifier      = module.database.db_instance_identifier
  elasticache_cluster_id = module.cache.cluster_id
}