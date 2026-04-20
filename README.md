# Lesson 7: Terraform + EKS + Helm

## Goal
This project provisions AWS infrastructure and deploys a Django application to Kubernetes with Helm:
1. Remote state backend (S3 + DynamoDB)
2. VPC network (public/private subnets)
3. ECR repository for Docker image
4. EKS cluster with managed node group
5. Helm chart with Deployment, Service, ConfigMap, HPA, and optional Ingress + TLS

## Project structure
```text
lesson-7/
|
|-- main.tf
|-- backend.tf
|-- outputs.tf
|-- modules/
|   |-- s3-backend/
|   |-- vpc/
|   |-- ecr/
|   `-- eks/
|       |-- eks.tf
|       |-- variables.tf
|       `-- outputs.tf
`-- charts/
		`-- django-app/
				|-- Chart.yaml
				|-- values.yaml
				`-- templates/
						|-- deployment.yaml
						|-- service.yaml
						|-- configmap.yaml
						|-- hpa.yaml
						`-- ingress.yaml
```

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured (`aws configure`)
- Docker
- kubectl
- Helm

## Commands from scratch (full order)

Run from project root (`lesson-7/`).

### 0. Optional: verify tool versions
```bash
terraform -version
aws --version
docker --version
kubectl version --client
helm version
```

### 1. Bootstrap remote state backend (S3 + DynamoDB)
This step is needed once for a new AWS account/region.

```bash
terraform init -backend=false
terraform apply -target=module.s3_backend -auto-approve
```

### 2. Switch Terraform to remote backend
```bash
terraform init -reconfigure -migrate-state
```

### 3. Create core infrastructure (VPC + ECR + EKS)
```bash
terraform plan
terraform apply -auto-approve
```

Useful outputs:
- `ecr_repository_url`
- `eks_cluster_name`
- `kubectl_configure_command`

### 4. Configure kubectl access to EKS
```bash
aws eks update-kubeconfig --region us-west-2 --name woolf-goit-eks-usw2
kubectl get nodes
```

### 5. Build and push Django image to ECR
Account: `<AWS_ACCOUNT_ID>`, image tag: `v1.0.0`.

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com

docker build -t woolf-goit-app-ecr-usw2:v1.0.0 .
docker tag woolf-goit-app-ecr-usw2:v1.0.0 <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/woolf-goit-app-ecr-usw2:v1.0.0
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/woolf-goit-app-ecr-usw2:v1.0.0
```

### 6. Verify Helm chart before deploy
```bash
helm lint ./charts/django-app
helm template django-app ./charts/django-app > $null
```

### 7. Deploy app with Helm
```bash
helm upgrade --install django-app ./charts/django-app -n django --create-namespace
kubectl get deploy,po,svc,hpa -n django
```

### 8. Post-deploy checks (acceptance)
```bash
kubectl describe deployment django-app-django-app -n django
kubectl get configmap django-app-config -n django -o yaml
kubectl get svc django-app-django-app -n django
kubectl get hpa django-app-django-app -n django
```

If Service type `LoadBalancer` is still pending EXTERNAL-IP, wait 2-5 minutes and re-check:

```bash
kubectl get svc django-app-django-app -n django -w
```

### 9. Re-deploy after config/image changes
```bash
helm upgrade django-app ./charts/django-app -n django
```

### 10. Cleanup (optional)
```bash
helm uninstall django-app -n django
terraform destroy -auto-approve
```

The chart implements:
- Deployment with `envFrom` from ConfigMap
- Service of type `LoadBalancer`
- HPA from 2 to 6 replicas with CPU target 70%
- ConfigMap for application environment variables

## ConfigMap environment variables
Set your application env values in:
`charts/django-app/values.yaml` -> `config.env`

## Bonus: Ingress + TLS
Enable in `charts/django-app/values.yaml`:
```yaml
ingress:
  enabled: true
  className: nginx
  host: django.lesson7.local
  path: /
  pathType: Prefix
  tls: true
  clusterIssuer: letsencrypt-prod
```

Install cert-manager and ingress controller beforehand.

## Acceptance checklist
1. EKS cluster is created and nodes are Ready.
2. ECR repository exists and contains Django image.
3. Deployment, Service and HPA are deployed with Helm.
4. ConfigMap is mounted via `envFrom` in Deployment.
