resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argo_cd" {
  name             = var.release_name
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  create_namespace = false
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argo_apps" {
  name             = "argo-apps"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  chart            = "${path.module}/charts/argo-apps"
  create_namespace = false

  values = [
    yamlencode({
      applications = [
        {
          name           = var.app_release_name
          namespace      = kubernetes_namespace.argocd.metadata[0].name
          project        = "default"
          sourceRepoURL  = var.app_repo_url
          sourcePath     = var.app_chart_path
          targetRevision = var.app_target_revision
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = var.app_namespace
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = [
              "CreateNamespace=true"
            ]
          }
        }
      ]
      repositories = []
    })
  ]

  depends_on = [helm_release.argo_cd]
}
