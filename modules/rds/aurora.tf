resource "aws_rds_cluster" "this" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier              = "${var.name_prefix}-cluster"
  engine                          = var.engine
  engine_version                  = local.engine_version_effective
  database_name                   = var.db_name
  master_username                 = var.master_username
  master_password                 = var.master_password
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster[0].name
  backup_retention_period         = var.backup_retention_period
  deletion_protection             = var.deletion_protection
  storage_encrypted               = true
  skip_final_snapshot             = var.skip_final_snapshot
  apply_immediately               = var.apply_immediately

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-cluster"
    ManagedBy = "Terraform"
  })
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  identifier              = "${var.name_prefix}-writer-1"
  cluster_identifier      = aws_rds_cluster.this[0].id
  engine                  = var.engine
  engine_version          = local.engine_version_effective
  instance_class          = var.instance_class
  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_parameter_group_name = aws_db_parameter_group.aurora_instance[0].name
  publicly_accessible     = false
  apply_immediately       = var.apply_immediately

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-writer-1"
    ManagedBy = "Terraform"
  })
}
