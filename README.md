# Lesson 10: Flexible Terraform RDS Module (RDS or Aurora)

## Goal
Build a production-ready reusable Terraform module that can create:
- a regular AWS RDS instance (PostgreSQL or MySQL)
- or an Aurora cluster (Aurora PostgreSQL or Aurora MySQL)

The mode is controlled by one flag:
- `use_aurora = false` -> regular RDS instance
- `use_aurora = true` -> Aurora cluster + writer instance

## What is implemented
This repository contains full infrastructure and CI/CD modules, plus the Lesson 10 database module.

Available modules:
- `modules/s3-backend` - S3 bucket and DynamoDB lock table for Terraform state
- `modules/vpc` - VPC, subnets, routing, internet/NAT gateways
- `modules/ecr` - ECR repository
- `modules/eks` - EKS cluster and managed node group
- `modules/jenkins` - Jenkins via Helm
- `modules/argo_cd` - Argo CD via Helm
- `modules/rds` - universal database module for Lesson 10

## Lesson 10 requirements coverage
The `modules/rds` module provides:
- conditional creation of Aurora or regular RDS using `use_aurora`
- automatic creation of `aws_db_subnet_group`
- automatic creation of `aws_security_group`
- parameter group(s) with base parameters:
  - PostgreSQL family: `max_connections`, `log_statement`, `work_mem`
  - MySQL family: `max_connections`
- typed variables with descriptions and defaults
- outputs for endpoint, port, identifier and mode

Strict compatibility rules are enforced:
- `use_aurora = true` requires `engine = aurora-postgresql` or `aurora-mysql`
- `use_aurora = false` requires `engine = postgres` or `mysql`

## Module structure
`modules/rds` contains:
- `shared.tf` - shared resources (subnet group, security group, parameter group logic)
- `rds.tf` - regular `aws_db_instance` path
- `aurora.tf` - Aurora cluster + writer path
- `variables.tf` - typed inputs
- `outputs.tf` - module outputs

## Example module usage
```hcl
module "rds" {
  source              = "./modules/rds"
  name_prefix         = "woolf-goit-db-usw2"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  use_aurora     = false
  engine         = "postgres"
  engine_version = "16.3" # optional: if omitted, module uses engine-specific default
  instance_class = "db.t3.micro"
  multi_az       = false

  db_name         = "appdb"
  master_username = "appuser"
  master_password = var.db_master_password

  tags = local.common_tags
}
```

## How to switch DB type
Regular RDS:
```hcl
use_aurora = false
engine     = "postgres" # or "mysql"
```

Aurora:
```hcl
use_aurora = true
engine     = "aurora-postgresql" # or "aurora-mysql"
```

Compatibility matrix:
- `use_aurora=false` + `engine=postgres|mysql` -> `aws_db_instance`
- `use_aurora=true` + `engine=aurora-postgresql|aurora-mysql` -> `aws_rds_cluster` + `aws_rds_cluster_instance` (writer)

## Variables reference
- `name_prefix` (string): Prefix for DB resource names.
- `vpc_id` (string): VPC ID for the database security group.
- `subnet_ids` (list(string)): Subnet IDs for DB subnet group.
- `allowed_cidr_blocks` (list(string), default `10.0.0.0/16`): CIDRs allowed to access DB port.
- `use_aurora` (bool, default `false`): Enables Aurora mode.
- `engine` (string, default `postgres`): `postgres`, `mysql`, `aurora-postgresql`, `aurora-mysql`.
- `engine_version` (string, default `null`): Engine version. If omitted, module auto-selects a safe default per engine.
- `instance_class` (string, default `db.t3.micro`): DB instance class.
- `multi_az` (bool, default `false`): Multi-AZ for regular RDS only.
- `db_name` (string, default `appdb`): Initial database name.
- `master_username` (string, default `appuser`): Database admin username.
- `master_password` (string, sensitive): Database admin password.
- `allocated_storage` (number, default `20`): Storage for regular RDS.
- `max_allocated_storage` (number, default `100`): Max autoscaled storage for regular RDS.
- `storage_type` (string, default `gp3`): Storage type for regular RDS.
- `backup_retention_period` (number, default `7`): Backup retention days.
- `deletion_protection` (bool, default `false`): Deletion protection toggle.
- `skip_final_snapshot` (bool, default `true`): Skip final snapshot on destroy.
- `apply_immediately` (bool, default `true`): Apply changes immediately.
- `parameter_group_family_override` (string, default empty): Optional explicit PG family.
- `tags` (map(string), default `{}`): Resource tags.

Engine version defaults when `engine_version = null`:
- `postgres` -> `16.3`
- `mysql` -> `8.0.39`
- `aurora-postgresql` -> `16.3`
- `aurora-mysql` -> `8.0.mysql_aurora.3.08.0`

## Secrets best practice
Do not store DB passwords directly in `main.tf`.

Option 1 (recommended): environment variable
```bash
export TF_VAR_db_master_password="StrongPasswordHere"
```

Option 2: `terraform.tfvars` (do not commit this file)
```hcl
db_master_password = "StrongPasswordHere"
```

## Outputs
Module outputs:
- `db_identifier`
- `db_endpoint`
- `db_port`
- `db_engine`
- `is_aurora`
- `db_subnet_group_name`
- `security_group_id`
- `parameter_group_name`
- `aurora_cluster_parameter_group_name`

Root outputs expose key DB values via `module.rds`.

## Full deployment guide

### 1. Prerequisites
- Terraform >= 1.5
- AWS CLI configured (`aws configure`)
- kubectl
- Helm
- Access to AWS account with permissions for VPC, EKS, ECR, RDS, IAM, EC2, S3, DynamoDB

### 2. Update project-specific values before apply
In `main.tf`, review and update:
- `module.s3_backend.bucket_name` (must be globally unique)
- `module.argo_cd.app_repo_url` (your actual Git repository URL)
- `db_master_password` (strong password via TF_VAR or tfvars)
- optional RDS mode and engine values (`use_aurora`, `engine`, `engine_version`, `instance_class`, `multi_az`)

### 3. Bootstrap Terraform backend (one-time)
```bash
terraform init -backend=false
terraform apply -target=module.s3_backend -auto-approve
```

### 4. Reinitialize Terraform with remote backend
```bash
terraform init -reconfigure -migrate-state
```

### 5. Validate and inspect plan
```bash
terraform fmt -recursive
terraform validate
terraform plan
```

### 6. Deploy full infrastructure
```bash
terraform apply -auto-approve
```

### 7. Configure kubectl for EKS
```bash
aws eks update-kubeconfig --region us-west-2 --name woolf-goit-eks-usw2
kubectl get nodes
```

### 8. Verify database deployment
```bash
terraform output db_identifier
terraform output db_endpoint
terraform output db_port
terraform output db_engine
terraform output is_aurora
```

### 9. Verify Jenkins and Argo CD (if required by your flow)
```bash
kubectl get svc -n jenkins
kubectl get pods -n argocd
kubectl get svc -n argocd
```

Get Argo CD initial admin password:
```bash
kubectl -n argocd get secret argo-cd-argocd-initial-admin-secret -o jsonpath={.data.password} | base64 --decode; echo
```

### 10. Optional destroy
```bash
terraform destroy
```

If `skip_final_snapshot = false`, AWS will require final snapshot settings before DB deletion.

## Useful files
- `main.tf` - root modules wiring
- `outputs.tf` - root outputs including database outputs
- `modules/rds/variables.tf` - all database module variables
- `modules/rds/shared.tf` - shared DB resources and parameter groups
- `modules/rds/rds.tf` - regular RDS path
- `modules/rds/aurora.tf` - Aurora path
- `modules/rds/outputs.tf` - module outputs
