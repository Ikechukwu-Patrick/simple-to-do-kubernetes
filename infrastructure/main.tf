module "aws_infra" {
  source     = "./modules/aws_resources"
  app_name   = var.app_name
  env_suffix = var.environment
}

module "k8s_cluster" {
  source   = "./modules/kind_cluster"
  app_name = var.app_name
}

module "k8s_app" {
  source         = "./modules/k8s_app"
  app_name       = var.app_name
  environment    = var.environment
  s3_bucket_name = module.aws_infra.s3_bucket_name
  replica_count  = var.app_replicas
  depends_on     = [module.k8s_cluster]
}

module "monitoring" {
  source        = "./modules/monitoring"
  redis_password = var.redis_password
  depends_on    = [module.k8s_cluster]
}

module "database" {
  source      = "./modules/database"
  db_password = var.db_password
  depends_on  = [module.k8s_cluster]
}

module "redis" {
  source         = "./modules/redis"
  redis_password = var.redis_password
  depends_on     = [module.k8s_cluster]
}

module "ci_cd" {
  source    = "./modules/ci_cd"
  depends_on = [module.k8s_cluster]
}
module "k8s_app" {
  source         = "./modules/k8s_app"
  app_name       = var.app_name          # From root variables
  environment    = var.environment       # From root variables
  s3_bucket_name = module.aws_infra.s3_bucket_name  # From aws_infra module
  replica_count  = var.app_replicas      # Number of pods
  image_version  = "latest"              # Or from variables
}

module "aws_infra" {
  source     = "./modules/aws_resources"
  app_name   = var.app_name
  env_suffix = var.environment
}

module "k8s_cluster" {
  source   = "./modules/kind_cluster"
  app_name = var.app_name
}

module "k8s_app" {
  source         = "./modules/k8s_app"
  app_name       = var.app_name
  environment    = var.environment
  s3_bucket_name = module.aws_infra.s3_bucket_name
  replica_count  = var.app_replicas
  image_version  = "latest"
  depends_on     = [module.k8s_cluster]
}