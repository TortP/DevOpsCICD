terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  common_tags = {
    Project     = "woolf-goit-lesson-8-9"
    Environment = "dev"
    Region      = "us-west-2"
    ManagedBy   = "Terraform"
  }
}

# S3 + DynamoDB for Terraform remote state and state locking.
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "woolf-goit-tfstate-usw2-20260417"
  table_name  = "terraform-locks-usw2"
  tags        = local.common_tags
}

# VPC with 3 public and 3 private subnets.
module "vpc" {
  source                  = "./modules/vpc"
  vpc_cidr_block          = "10.0.0.0/16"
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets         = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name                = "woolf-goit-vpc-usw2"
  kubernetes_cluster_name = "woolf-goit-eks-usw2"
  tags                    = local.common_tags
}

# ECR repository for Docker images.
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "woolf-goit-app-ecr-usw2"
  scan_on_push = true
  tags         = local.common_tags
}

# EKS cluster and managed node group in existing VPC private subnets.
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "woolf-goit-eks-usw2"
  kubernetes_version = "1.31"
  subnet_ids         = module.vpc.private_subnet_ids
  node_group_name    = "woolf-goit-ng"
  instance_types     = ["t3.medium"]
  desired_size       = 2
  min_size           = 2
  max_size           = 4
  tags               = local.common_tags
}

# Jenkins installed via Helm to run CI pipeline in-cluster.
module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.cluster_name
}

# Argo CD installed via Helm for GitOps CD sync.
module "argo_cd" {
  source              = "./modules/argo_cd"
  cluster_name        = module.eks.cluster_name
  app_repo_url        = "https://github.com/TortP/DevOpsCICD.git"
  app_target_revision = "main"
  app_chart_path      = "charts/django-app"
  app_namespace       = "django"
  app_release_name    = "django-app"
}
