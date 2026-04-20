variable "cluster_name" {
  description = "EKS cluster name where Jenkins will be installed"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.51"
}

variable "release_name" {
  description = "Jenkins Helm release name"
  type        = string
  default     = "jenkins"
}
