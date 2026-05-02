output "s3_backend_bucket_url" {
  description = "S3 bucket URL used for Terraform state storage"
  value       = module.s3_backend.bucket_url
}

output "dynamodb_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "Created VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "EKS managed node group name"
  value       = module.eks.node_group_name
}

output "kubectl_configure_command" {
  description = "Command to configure kubectl access to EKS"
  value       = "aws eks update-kubeconfig --region us-west-2 --name ${module.eks.cluster_name}"
}

output "jenkins_namespace" {
  description = "Namespace where Jenkins is installed"
  value       = module.jenkins.namespace
}

output "jenkins_admin_password_command" {
  description = "Command to get Jenkins initial admin password"
  value       = module.jenkins.admin_password_command
}

output "argo_cd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = module.argo_cd.namespace
}

output "argo_cd_initial_admin_password_command" {
  description = "Command to get Argo CD initial admin password"
  value       = module.argo_cd.initial_admin_password_command
}

output "monitoring_namespace" {
  description = "Namespace where monitoring stack is installed"
  value       = module.monitoring.namespace
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = module.monitoring.grafana_service_name
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = module.monitoring.prometheus_service_name
}

output "db_identifier" {
  description = "RDS instance ID or Aurora cluster ID"
  value       = module.rds.db_identifier
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "Database port"
  value       = module.rds.db_port
}

output "db_engine" {
  description = "Database engine in use"
  value       = module.rds.db_engine
}

output "is_aurora" {
  description = "Whether Aurora mode is enabled"
  value       = module.rds.is_aurora
}
