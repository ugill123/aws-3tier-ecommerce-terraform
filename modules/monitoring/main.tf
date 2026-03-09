locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. ALERTING
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# 2. VPC FLOW LOGS
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${local.name_prefix}-flow-logs"
  retention_in_days = 7
}

data "aws_iam_policy_document" "flow_log_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_log_role" {
  name               = "${local.name_prefix}-flow-log-role"
  assume_role_policy = data.aws_iam_policy_document.flow_log_assume_role.json
}

data "aws_iam_policy_document" "flow_log_policy" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
    resources = ["${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"]
  }
}

resource "aws_iam_role_policy" "flow_log_policy_attachment" {
  name   = "${local.name_prefix}-flow-log-policy"
  role   = aws_iam_role.flow_log_role.id
  policy = data.aws_iam_policy_document.flow_log_policy.json
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}

# 3. CRITICAL ALARMS
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${local.name_prefix}-asg-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "EC2 CPU exceeds 85%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { AutoScalingGroupName = var.asg_name }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${local.name_prefix}-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "10+ 5xx errors in 1 min"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
}

resource "aws_cloudwatch_metric_alarm" "alb_high_latency" {
  alarm_name          = "${local.name_prefix}-alb-high-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "Response time over 2s"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { LoadBalancer = var.alb_arn_suffix }
}

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name          = "${local.name_prefix}-rds-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "DB CPU exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { DBInstanceIdentifier = var.rds_db_identifier }
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${local.name_prefix}-rds-low-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120
  alarm_description   = "DB Storage under 5GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { DBInstanceIdentifier = var.rds_db_identifier }
}

resource "aws_cloudwatch_metric_alarm" "redis_high_memory" {
  alarm_name          = "${local.name_prefix}-redis-high-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Redis Memory exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions          = { CacheClusterId = var.elasticache_cluster_id }
}

# 4. DASHBOARD
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-production-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      { type = "metric", x = 0, y = 0, width = 6, height = 6, properties = { title = "ALB Requests", region = "us-east-1", metrics = [["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]], stat = "Sum", period = 300 } },
      { type = "metric", x = 6, y = 0, width = 6, height = 6, properties = { title = "ALB Target Latency", region = "us-east-1", metrics = [["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix]], stat = "Average", period = 300 } },
      { type = "metric", x = 12, y = 0, width = 6, height = 6, properties = { title = "ALB 5xx Errors", region = "us-east-1", metrics = [["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]], stat = "Sum", period = 300 } },
      { type = "metric", x = 18, y = 0, width = 6, height = 6, properties = { title = "ASG CPU Utilization", region = "us-east-1", metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name]], stat = "Average", period = 300 } },
      { type = "metric", x = 0, y = 6, width = 6, height = 6, properties = { title = "RDS CPU Utilization", region = "us-east-1", metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_db_identifier]], stat = "Average", period = 300 } },
      { type = "metric", x = 6, y = 6, width = 6, height = 6, properties = { title = "RDS DB Connections", region = "us-east-1", metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_db_identifier]], stat = "Average", period = 300 } },
      { type = "metric", x = 12, y = 6, width = 6, height = 6, properties = { title = "RDS Free Storage (Bytes)", region = "us-east-1", metrics = [["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_db_identifier]], stat = "Average", period = 300 } },
      { type = "metric", x = 0, y = 12, width = 6, height = 6, properties = { title = "Redis CPU Utilization", region = "us-east-1", metrics = [["AWS/ElastiCache", "CPUUtilization", "CacheClusterId", var.elasticache_cluster_id]], stat = "Average", period = 300 } },
      { type = "metric", x = 6, y = 12, width = 6, height = 6, properties = { title = "Redis Memory Usage (%)", region = "us-east-1", metrics = [["AWS/ElastiCache", "DatabaseMemoryUsagePercentage", "CacheClusterId", var.elasticache_cluster_id]], stat = "Average", period = 300 } },
      { type = "metric", x = 12, y = 12, width = 6, height = 6, properties = { title = "Redis Curr Connections", region = "us-east-1", metrics = [["AWS/ElastiCache", "CurrConnections", "CacheClusterId", var.elasticache_cluster_id]], stat = "Average", period = 300 } }
    ]
  })
}