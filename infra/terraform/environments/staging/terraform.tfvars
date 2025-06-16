# Staging Environment Configuration
# Customize these values for your staging environment

app_name    = "migration-guard-test-app"
environment = "staging"
aws_region  = "us-east-1"

# Instance configuration
instance_type = "t3.small"
min_instances = 1
max_instances = 3

# Database configuration
database_instance_class    = "db.t3.small"
database_allocated_storage = 20
