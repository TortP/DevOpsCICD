# Lesson 5: Terraform IaC for AWS

## Project goal
This project creates AWS infrastructure with Terraform modules:
1. Remote state backend (S3 + DynamoDB lock table)
2. Network layer (VPC with public and private subnets)
3. Container registry (ECR)

## Project structure
```text
lesson-5/
|
|-- main.tf
|-- backend.tf
|-- outputs.tf
|-- modules/
|   |-- s3-backend/
|   |   |-- s3.tf
|   |   |-- dynamodb.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   |-- vpc/
|   |   |-- vpc.tf
|   |   |-- routes.tf
|   |   |-- variables.tf
|   |   `-- outputs.tf
|   `-- ecr/
|       |-- ecr.tf
|       |-- variables.tf
|       `-- outputs.tf
`-- README.md
```

## Modules explanation
- `s3-backend`: creates a private S3 bucket for Terraform state, enables bucket versioning, enables SSE encryption, and creates DynamoDB table for state locking.
- `vpc`: creates VPC, 3 public subnets, 3 private subnets, Internet Gateway, one NAT Gateway, public/private route tables and associations.
- `ecr`: creates ECR repository with image scanning on push and repository policy for account push/pull access.

## Standard Terraform commands
```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Current defaults
- AWS region: `us-west-2`
- Terraform state bucket: `woolf-goit-tfstate-usw2-20260417`
- Terraform lock table: `terraform-locks-usw2`
- VPC name: `woolf-goit-vpc-usw2`
- ECR name: `woolf-goit-app-ecr-usw2`
- VPC CIDR: `10.0.0.0/16`
- Public subnets: `10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`
- Private subnets: `10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24`
