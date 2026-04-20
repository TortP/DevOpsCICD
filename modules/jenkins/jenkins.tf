resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "jenkins" {
  name             = var.release_name
  namespace        = kubernetes_namespace.jenkins.metadata[0].name
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = var.chart_version
  create_namespace = false
  timeout          = 900

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_namespace.jenkins]
}
