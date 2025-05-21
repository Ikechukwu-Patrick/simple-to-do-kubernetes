terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate-localstack"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    # LocalStack endpoint override
    endpoints {
      s3 = "http://localhost:4566"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    ec2       = "http://localhost:4566"
    eks       = "http://localhost:4566"
    iam       = "http://localhost:4566"
    s3        = "http://localhost:4566"
    ecr       = "http://localhost:4566"
    ecs       = "http://localhost:4566"
  }
}

module "vpc" {
  source = "./vpc"
}

module "s3" {
  source = "./s3"
}

module "iam" {
  source = "./iam"
  vpc_id = module.vpc.vpc_id
}

module "eks" {
  source     = "./eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}