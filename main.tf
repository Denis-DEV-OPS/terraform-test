provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "gdv-tf-eks"
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

 eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

    two = {
      name = "node-group-2"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

resource "aws_ecr_repository" "gdv_ecr_repo" {
  name = "gdv-ecr-repo"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state"

  tags = {
    Name = "gdv bucket"
  }

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
