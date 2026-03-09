locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. Fetch the latest Amazon Linux 2023 AMI dynamically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. The Launch Template (The blueprint for your EC2 instances)

resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-app-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  vpc_security_group_ids = [var.app_sg_id]

  # Reads the external bash script and dynamically injects Terraform variables
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    project        = var.project
    db_endpoint    = var.db_endpoint
    redis_endpoint = var.redis_endpoint
    db_secret_arn  = var.db_secret_arn
  }))

  tags = {
    Name = "${local.name_prefix}-launch-template"
  }
}

# 3. The Auto Scaling Group (Manages the EC2 instances)
resource "aws_autoscaling_group" "app_asg" {
  name                = "${local.name_prefix}-app-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  
  # Auto Scaling constraints (Deploying 1 instance per private AZ)
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # This tag propagates down to the actual EC2 instances it creates
  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app-server"
    propagate_at_launch = true
  }
}