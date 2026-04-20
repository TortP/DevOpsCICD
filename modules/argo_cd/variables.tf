variable "cluster_name" {
  description = "EKS cluster name where Argo CD will be installed"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Argo CD Helm release name"
  type        = string
  default     = "argo-cd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.7.16"
}

variable "app_repo_url" {
  description = "Git repository URL with Helm chart"
  type        = string
}

variable "app_target_revision" {
  description = "Git revision that Argo CD should track"
  type        = string
  default     = "main"
}

variable "app_chart_path" {
  description = "Path to Helm chart inside Git repository"
  type        = string
  default     = "charts/django-app"
}

variable "app_namespace" {
  description = "Namespace where Argo CD deploys the app"
  type        = string
  default     = "django"
}

variable "app_release_name" {
  description = "Helm release name managed by Argo CD"
  type        = string
  default     = "django-app"
}
