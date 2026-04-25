variable "name_prefix" {
  description = "Name prefix for all RDS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where database security group will be created"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for DB subnet group (at least 2 in different AZs)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for DB subnet group."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to the database"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "use_aurora" {
  description = "When true creates Aurora Cluster + writer instance, otherwise creates a single RDS instance"
  type        = bool
  default     = false

  validation {
    condition = (
      var.use_aurora && contains(["aurora-postgresql", "aurora-mysql"], var.engine)
      ) || (
      !var.use_aurora && contains(["postgres", "mysql"], var.engine)
    )
    error_message = "When use_aurora=true, engine must be aurora-postgresql or aurora-mysql. When use_aurora=false, engine must be postgres or mysql."
  }
}

variable "engine" {
  description = "Database engine. Use postgres/mysql for RDS, aurora-postgresql/aurora-mysql for Aurora"
  type        = string
  default     = "postgres"

  validation {
    condition = contains([
      "postgres",
      "mysql",
      "aurora-postgresql",
      "aurora-mysql"
    ], var.engine)
    error_message = "Supported engines: postgres, mysql, aurora-postgresql, aurora-mysql."
  }
}

variable "engine_version" {
  description = "Database engine version. If null, module chooses a safe default per engine"
  type        = string
  default     = null
  nullable    = true
}

variable "instance_class" {
  description = "Instance class for RDS instance or Aurora writer"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for regular RDS instance"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master username for database"
  type        = string
  default     = "appuser"
}

variable "master_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB for regular RDS instance"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling regular RDS instance"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type for regular RDS instance"
  type        = string
  default     = "gp3"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on delete"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply DB modifications immediately"
  type        = bool
  default     = true
}

variable "parameter_group_family_override" {
  description = "Optional explicit parameter group family override"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
