output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "The ARN of the Target Group (needed by the Auto Scaling Group)."
  value       = aws_lb_target_group.app_tg.arn
}
output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB (needed for CloudWatch Alarms)."
  value       = aws_lb.this.arn_suffix
}