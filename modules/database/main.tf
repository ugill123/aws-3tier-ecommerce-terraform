locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. DB Subnet Group (Tells RDS which subnets to use)
resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.database_subnet_ids
  
  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

# 2. Generate a highly secure random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 3. Provision the Multi-AZ RDS MySQL Instance
resource "aws_db_instance" "this" {
  identifier             = "${local.name_prefix}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro" # Cost-effective for assessments
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "ecommerce_db"
  username               = "admin"
  password               = random_password.db_password.result
  
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  multi_az               = true
  
  skip_final_snapshot    = true # Ensures clean teardown for assessments

  tags = {
    Name = "${local.name_prefix}-mysql"
  }
}

# 4. Store the Credentials securely in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name                    = "${local.name_prefix}-db-credentials"
  description             = "Database connection credentials and endpoints"
  recovery_window_in_days = 0 # Allows immediate deletion during terraform destroy
  
  tags = {
    Name = "${local.name_prefix}-db-secret"
  }
}

# 5. Save the JSON string containing the DB connection details
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.this.username
    password = aws_db_instance.this.password
    engine   = aws_db_instance.this.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = aws_db_instance.this.db_name
  })
}