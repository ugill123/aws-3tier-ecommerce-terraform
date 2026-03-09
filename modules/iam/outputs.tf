output "app_instance_profile_name" {
  description = "The name of the IAM instance profile to attach to EC2 instances."
  value       = aws_iam_instance_profile.app_profile.name
}

output "app_iam_role_arn" {
  description = "The ARN of the IAM role."
  value       = aws_iam_role.app_role.arn
}