terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.14"
    }
  }
  required_version = "~> 1.1"

  backend "s3" {
    bucket         = "kiririmode-tfbackend"
    key            = "cognito-sandbox"
    encrypt        = true
    dynamodb_table = "terraform_state"
    region         = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  # 全てのリソースに付与するタグ
  default_tags {
    tags = {
      Target    = "Cognito Sandbox"
      ManagedBy = "Terraform"
    }
  }
}
