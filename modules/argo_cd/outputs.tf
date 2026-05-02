output "namespace" {
  description = "Argo CD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Argo CD Helm release name"
  value       = helm_release.argo_cd.name
}

output "server_service_name" {
  description = "Argo CD server service name"
  value       = "${helm_release.argo_cd.name}-argocd-server"
}

output "initial_admin_password_command" {
  description = "Command to get Argo CD initial admin password"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret ${helm_release.argo_cd.name}-argocd-initial-admin-secret -o jsonpath={.data.password} | base64 --decode; echo"
}
