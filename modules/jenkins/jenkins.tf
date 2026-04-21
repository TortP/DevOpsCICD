resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

locals {
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

resource "kubernetes_secret" "kaniko_secret" {
  metadata {
    name      = "kaniko-secret"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "config.json" = jsonencode({
      credHelpers = {
        (local.ecr_registry) = "ecr-login"
      }
    })
  }

  type = "Opaque"
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

  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_secret.kaniko_secret
  ]
}
