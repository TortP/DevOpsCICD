output "namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "release_name" {
  description = "Monitoring Helm release name"
  value       = helm_release.kube_prometheus_stack.name
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = "grafana"
}

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = "${helm_release.kube_prometheus_stack.name}-prometheus"
}
