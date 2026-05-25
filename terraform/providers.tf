terraform {
  required_version = ">= 1.3"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
