# Production environment configuration

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  app_name    = var.app_name
  environment = var.environment
  cidr_block  = "10.0.0.0/16"
}

# Application Module
module "app" {
  source = "../../modules/app"
  
  app_name           = var.app_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  min_instances      = var.min_instances
  max_instances      = var.max_instances
}

# Database Module
module "database" {
  source = "../../modules/database"
  
  app_name                = var.app_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.database_subnet_ids
  allowed_security_groups = [module.app.security_group_id]
  instance_class          = var.database_instance_class
  allocated_storage       = var.database_allocated_storage
  max_allocated_storage   = var.database_allocated_storage * 2
  master_password         = random_password.database_password.result
  
  backup_retention_period = var.environment == "production" ? 30 : 7
}

# Redis Module
module "redis" {
  source = "../../modules/redis"
  
  app_name                = var.app_name
  environment             = var.environment
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.database_subnet_ids
  allowed_security_groups = [module.app.security_group_id]
  
  node_type                  = var.environment == "production" ? "cache.t3.small" : "cache.t3.micro"
  num_cache_clusters         = var.environment == "production" ? 2 : 1
  automatic_failover_enabled = var.environment == "production"
  auth_token                 = random_password.redis_password.result
}

# Random password for database
resource "random_password" "database_password" {
  length  = 32
  special = true
}

# Random password for Redis
resource "random_password" "redis_password" {
  length  = 32
  special = false  # Redis doesn't like special characters in auth tokens
}

# Store secrets in SSM Parameter Store
resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.app_name}/${var.environment}/database_url"
  type  = "SecureString"
  value = "postgresql://${module.database.username}:${random_password.database_password.result}@${module.database.endpoint}/${module.database.database_name}"
}

resource "aws_ssm_parameter" "redis_url" {
  name  = "/${var.app_name}/${var.environment}/redis_url"
  type  = "SecureString"
  value = "redis://default:${random_password.redis_password.result}@${module.redis.primary_endpoint}:${module.redis.port}"
}
