# Final Project: DevOps Infrastructure on AWS

## Overview
This repository contains a complete Terraform-based DevOps platform on AWS for the final course project.

Implemented components:
- VPC networking (subnets, routing, gateways)
- EKS Kubernetes cluster
- ECR container registry
- RDS/Aurora database module
- Jenkins (Helm) for CI
- Argo CD (Helm) for GitOps CD
- App Helm chart for Kubernetes deployment

## Repository structure

- main.tf: root module wiring and provider configuration
- backend.tf: remote state backend (S3 + DynamoDB)
- variables.tf: root input variables
- outputs.tf: root outputs
- Jenkinsfile: CI pipeline (build, push, GitOps values update)
- charts/django-app: application Helm chart
- modules/s3-backend: S3 bucket and DynamoDB lock table
- modules/vpc: networking module
- modules/ecr: ECR module
- modules/eks: EKS module
- modules/rds: database module (RDS or Aurora)
- modules/jenkins: Jenkins Helm deployment
- modules/argo_cd: Argo CD Helm deployment + apps chart
- modules/monitoring: Prometheus + Grafana Helm deployment

## Technical requirements

Infrastructure:
- AWS
- Terraform >= 1.5

Core services:
- VPC
- EKS
- RDS or Aurora
- ECR
- Jenkins
- Argo CD
- Prometheus
- Grafana

Tools:
- AWS CLI
- kubectl
- Helm

## Prerequisites

1. Configure AWS credentials:

```bash
aws configure
```

2. Export database password (recommended):

```bash
export TF_VAR_db_master_password="StrongPasswordHere"
```

3. Verify required values in main.tf before deployment:
- unique S3 bucket name for backend bootstrap module
- app_repo_url and app_target_revision for Argo CD
- ECR repository naming
- cluster naming and region

4. When deploying the Django Helm chart, provide `secret.value` for `charts/django-app` or pre-create the `django-app-secret` Secret in the target namespace.

## Deployment steps

### 1. Initialize Terraform

If backend infrastructure already exists:

```bash
terraform init
```

If this is the first deployment in a fresh account:

```bash
terraform init -backend=false
terraform apply -target=module.s3_backend -auto-approve
terraform init -reconfigure -migrate-state
```

### 2. Validate and plan

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

### 3. Deploy infrastructure

First deploy should be done in two stages because Jenkins/Argo CD/Monitoring modules
use EKS data sources and require an existing cluster endpoint.

Stage 1: create core AWS infrastructure:

```bash
terraform apply -target=module.vpc -target=module.ecr -target=module.rds -target=module.eks
```

Stage 2: deploy in-cluster services:

```bash
terraform apply
```

For subsequent updates, a single apply is enough:

```bash
terraform apply
```

## Post-deploy checks

### Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region us-west-2 --name woolf-goit-eks-usw2
kubectl get nodes
```

### Check namespaces/services

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Access services via port-forward

Jenkins:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Argo CD:

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

## CI/CD demonstration flow

1. Push code changes to branch final-project.
2. Jenkins pipeline builds image and pushes to ECR. Set the `AWS_ACCOUNT_ID` parameter when running the job.
3. Jenkins updates image tag in charts/django-app/values.yaml.
4. Argo CD detects Git change and syncs deployment to EKS.
5. Verify rollout in Kubernetes.

## Monitoring checks

1. Open Grafana via local port-forward.
2. Validate dashboards and data sources.
3. Confirm application and cluster metrics are visible.
4. Optionally inspect Prometheus targets.

## Safety and cleanup

Important: cloud resources generate costs while running.

After verification, clean up resources:

```bash
terraform destroy
```

### Important backend note after destroy

If terraform destroy removed all infrastructure including backend bootstrap resources,
S3 bucket and DynamoDB lock table for Terraform state are also removed.

Before the next deployment, recreate backend infrastructure in this order:

```bash
terraform init -backend=false
terraform apply -target=module.s3_backend -auto-approve
terraform init -reconfigure -migrate-state
```


