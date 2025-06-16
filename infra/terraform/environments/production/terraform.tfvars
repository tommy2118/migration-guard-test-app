# Production Environment Configuration
# Customize these values for your production environment

app_name    = "migration-guard-test-app"
environment = "production"
aws_region  = "us-east-1"

# Instance configuration
instance_type = "t3.medium"
min_instances = 2
max_instances = 10

# Database configuration
database_instance_class    = "db.t3.medium"
database_allocated_storage = 100
