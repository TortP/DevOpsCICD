variable "db_master_password" {
  description = "Master password for the database module (set via tfvars or TF_VAR_db_master_password)"
  type        = string
  sensitive   = true
}
