output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "service_name" {
  description = "Jenkins service name"
  value       = "${helm_release.jenkins.name}.${kubernetes_namespace.jenkins.metadata[0].name}.svc.cluster.local"
}

output "admin_password_command" {
  description = "Command to get initial Jenkins admin password"
  value       = "kubectl exec -n ${kubernetes_namespace.jenkins.metadata[0].name} svc/${helm_release.jenkins.name} -c jenkins -- cat /run/secrets/additional/chart-admin-password && echo"
}
