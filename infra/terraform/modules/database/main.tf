# Database infrastructure module

locals {
  name_prefix = "${var.app_name}-${var.environment}"
}

# Security Group for RDS
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}-db-"
  description = "Security group for ${var.app_name} database"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "database" {
  name_prefix = "${local.name_prefix}-"
  subnet_ids  = var.subnet_ids
  
  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "database" {
  identifier_prefix = "${local.name_prefix}-"
  
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  storage_type          = "gp3"
  
  db_name  = replace(var.app_name, "-", "_")
  username = var.master_username
  password = var.master_password
  
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.database.name
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  skip_final_snapshot       = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${local.name_prefix}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null
  
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  tags = {
    Name = "${local.name_prefix}-database"
  }
}

# Parameter Group
resource "aws_db_parameter_group" "database" {
  name_prefix = "${local.name_prefix}-"
  family      = var.parameter_group_family
  
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
