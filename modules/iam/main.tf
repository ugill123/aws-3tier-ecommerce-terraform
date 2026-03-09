locals {
  name_prefix = "${var.project}-${var.environment}"
}

# 1. Trust Policy: Allows EC2 instances to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app_role" {
  name               = "${local.name_prefix}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${local.name_prefix}-app-role"
  }
}

# 2. Custom Policy: Allow reading from Secrets Manager & writing to CloudWatch
data "aws_iam_policy_document" "app_custom_policy" {
  statement {
    sid       = "AllowSecretsManagerRead"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"] # In a strict prod environment, limit this to the exact Secret ARN
  }

  statement {
    sid       = "AllowCloudWatchLogs"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app_policy" {
  name        = "${local.name_prefix}-app-custom-policy"
  description = "Allows EC2 to read Secrets Manager and write CloudWatch Logs"
  policy      = data.aws_iam_policy_document.app_custom_policy.json
}

# 3. Attach Custom Policy to Role
resource "aws_iam_role_policy_attachment" "app_custom_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# 4. Attach SSM Core Policy (Allows secure console access without SSH keys)
resource "aws_iam_role_policy_attachment" "app_ssm_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 5. The Instance Profile (This is what actually gets attached to the EC2 instances)
resource "aws_iam_instance_profile" "app_profile" {
  name = "${local.name_prefix}-app-profile"
  role = aws_iam_role.app_role.name
}