variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets) == 3
    error_message = "Exactly 3 public subnets are required."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets) == 3
    error_message = "Exactly 3 private subnets are required."
  }
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly 3 availability zones are required."
  }
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "Optional EKS cluster name for subnet discovery tags"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
