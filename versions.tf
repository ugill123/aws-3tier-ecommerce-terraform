terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "your bucket name"
    key            = "apps/ecomerece-3tier-app/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb name"
    encrypt        = true
    profile        = "sso profile name"
  }
}