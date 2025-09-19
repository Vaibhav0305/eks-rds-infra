output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_port" {
  value = module.rds.db_instance_port
}

output "rds_master_username" {
  value = var.db_username
}

output "rds_master_password" {
  description = "RDS master password (sensitive)"
  value       = random_password.rds_master.result
  sensitive   = true
}

output "ecr_repo_uri" {
  value = try(aws_ecr_repository.api_repo[0].repository_url, "")
}
