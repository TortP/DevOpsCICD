output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "security_group_id" {
  description = "Security group ID used by the database"
  value       = aws_security_group.this.id
}

output "parameter_group_name" {
  description = "Parameter group name for regular RDS instance"
  value       = var.use_aurora ? null : aws_db_parameter_group.rds[0].name
}

output "aurora_cluster_parameter_group_name" {
  description = "Cluster parameter group name for Aurora"
  value       = var.use_aurora ? aws_rds_cluster_parameter_group.aurora_cluster[0].name : null
}

output "db_identifier" {
  description = "RDS instance ID or Aurora cluster ID"
  value       = var.use_aurora ? aws_rds_cluster.this[0].id : aws_db_instance.this[0].id
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "db_port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.this[0].port : aws_db_instance.this[0].port
}

output "db_engine" {
  description = "Database engine in use"
  value       = var.engine
}

output "is_aurora" {
  description = "Whether Aurora mode is enabled"
  value       = var.use_aurora
}
