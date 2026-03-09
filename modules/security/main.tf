locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. ALB Security Group (Public facing)
resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere
  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# 2. Application Tier Security Group (Private)
resource "aws_security_group" "app_sg" {
  name        = "${local.name_prefix}-app-sg"
  description = "Security group for EC2 Application Servers"
  vpc_id      = var.vpc_id

  # ONLY allow traffic from the ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow all outbound traffic (needed to download packages/updates via NAT)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-sg"
  }
}

# 3. Database Tier Security Group (Isolated)
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "Security group for RDS MySQL Database"
  vpc_id      = var.vpc_id

  # ONLY allow MySQL traffic from the App Servers
  ingress {
    description     = "MySQL from App Tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # Databases typically only need to reply to established connections, 
  # but standard practice allows all outbound to simplify VPC endpoint routing if added later.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-db-sg"
  }
}

# 4. Cache Tier Security Group (Isolated)
resource "aws_security_group" "cache_sg" {
  name        = "${local.name_prefix}-cache-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  # ONLY allow Redis traffic from the App Servers
  ingress {
    description     = "Redis from App Tier"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-cache-sg"
  }
}