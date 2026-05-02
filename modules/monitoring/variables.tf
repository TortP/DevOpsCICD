variable "cluster_name" {
  description = "EKS cluster name where monitoring stack will be installed"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring"
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Helm release name for kube-prometheus-stack"
  type        = string
  default     = "kube-prometheus-stack"
}

variable "chart_version" {
  description = "kube-prometheus-stack chart version"
  type        = string
  default     = "69.8.2"
}
