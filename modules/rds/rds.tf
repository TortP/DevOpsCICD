resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier              = "${var.name_prefix}-instance"
  engine                  = var.engine
  engine_version          = local.engine_version_effective
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.master_username
  password                = var.master_password
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  storage_type            = var.storage_type
  multi_az                = var.multi_az
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.this.id]
  parameter_group_name    = aws_db_parameter_group.rds[0].name
  backup_retention_period = var.backup_retention_period
  deletion_protection     = var.deletion_protection
  storage_encrypted       = true
  skip_final_snapshot     = var.skip_final_snapshot
  apply_immediately       = var.apply_immediately
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-instance"
    ManagedBy = "Terraform"
  })
}
