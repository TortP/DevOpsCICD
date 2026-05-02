locals {
  engine_version_effective = (
    var.engine_version != null && trim(var.engine_version) != ""
    ) ? var.engine_version : (
    var.engine == "postgres" ? "16.3" :
    var.engine == "mysql" ? "8.0.39" :
    var.engine == "aurora-postgresql" ? "16.3" :
    "8.0.mysql_aurora.3.08.0"
  )

  engine_major       = split(".", local.engine_version_effective)[0]
  engine_major_minor = join(".", slice(split(".", local.engine_version_effective), 0, 2))

  database_port = contains(["postgres", "aurora-postgresql"], var.engine) ? 5432 : 3306

  parameter_group_family = var.parameter_group_family_override != "" ? var.parameter_group_family_override : (
    var.engine == "postgres" ? "postgres${local.engine_major}" :
    var.engine == "mysql" ? "mysql${local.engine_major_minor}" :
    var.engine == "aurora-postgresql" ? "aurora-postgresql${local.engine_major}" :
    "aurora-mysql${local.engine_major_minor}"
  )

  is_postgres_engine = contains(["postgres", "aurora-postgresql"], var.engine)

  base_parameters = local.is_postgres_engine ? {
    max_connections = "200"
    log_statement   = "ddl"
    work_mem        = "4096"
    } : {
    max_connections = "200"
  }
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-subnet-group"
  description = "DB subnet group for ${var.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-subnet-group"
    ManagedBy = "Terraform"
  })
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-sg"
  description = "Security group for ${var.name_prefix} database"
  vpc_id      = var.vpc_id

  ingress {
    description = "DB access"
    from_port   = local.database_port
    to_port     = local.database_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-sg"
    ManagedBy = "Terraform"
  })
}

resource "aws_db_parameter_group" "rds" {
  count = var.use_aurora ? 0 : 1

  name        = "${var.name_prefix}-rds-pg"
  family      = local.parameter_group_family
  description = "Parameter group for ${var.name_prefix} RDS"

  dynamic "parameter" {
    for_each = local.base_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-rds-pg"
    ManagedBy = "Terraform"
  })
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.name_prefix}-aurora-cluster-pg"
  family      = local.parameter_group_family
  description = "Cluster parameter group for ${var.name_prefix} Aurora"

  dynamic "parameter" {
    for_each = local.base_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-aurora-cluster-pg"
    ManagedBy = "Terraform"
  })
}

resource "aws_db_parameter_group" "aurora_instance" {
  count = var.use_aurora ? 1 : 0

  name        = "${var.name_prefix}-aurora-instance-pg"
  family      = local.parameter_group_family
  description = "Instance parameter group for ${var.name_prefix} Aurora writer"

  dynamic "parameter" {
    for_each = local.base_parameters

    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-aurora-instance-pg"
    ManagedBy = "Terraform"
  })
}
