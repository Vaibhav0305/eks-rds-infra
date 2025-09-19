resource "random_password" "rds_master" {
  length  = 16
  special = true
}

resource "random_pet" "suffix" {
  length = 2
}

locals {
  name_suffix = "-${random_pet.suffix.id}"
  full_name   = "${var.cluster_name}${local.name_suffix}"
}

#######################################
# VPC
#######################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "${var.environment}-poc-vpc${local.name_suffix}"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

data "aws_availability_zones" "available" {}

#######################################
# ECR
#######################################
resource "aws_ecr_repository" "api_repo" {
  count = var.enable_ecr ? 1 : 0
  name  = "${var.environment}-api-repo${local.name_suffix}"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
  }
}

#######################################
# EKS (v19.x syntax)
#######################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.full_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_group_instance_type]
      min_size       = 1
      max_size       = var.node_group_desired_capacity + 1
      desired_size   = var.node_group_desired_capacity
    }
  }

  enable_irsa = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

#######################################
# Security Group for RDS
#######################################
resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg${local.name_suffix}"
  description = "Allow DB access from EKS nodes"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_eks_to_rds" {
  description              = "Allow EKS nodes to reach RDS"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = module.eks.node_security_group_id
}

#######################################
# RDS Postgres
#######################################
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.12.0"

  identifier        = "${var.environment}-poc-rds${local.name_suffix}"
  engine            = "postgres"
  engine_version    = var.db_engine_version
  family            = "postgres15"   # ✅ aligned with db_engine_version
  instance_class    = "db.t3.medium"
  allocated_storage = var.db_allocated_storage

  db_name  = "pocdb"
  username = var.db_username
  password = random_password.rds_master.result

  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  multi_az            = false
  storage_encrypted   = true
  skip_final_snapshot = true
}

