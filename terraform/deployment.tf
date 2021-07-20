resource "kubernetes_secret" "weatherapi" {
  metadata {
    name = "ecr-registry"
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${local.registry_server}": {
      "auth": "${base64encode("${var.registry_username}:${var.registry_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}

######################################################################################################

resource "kubernetes_deployment" "weatherapi" {
  metadata {
    name = "weatherapi"
    labels = {
      App = "weatherapi"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "weatherapi"
      }
    }
    template {
      metadata {
        labels = {
          App = "weatherapi"
        }
      }
      spec {
       image_pull_secrets {
          name = kubernetes_secret.weatherapi.metadata.0.name
        }      
        container {
          image = "${local.image_name}"
          name  = "weatherapi"

          port {
            container_port = 80
          }

        }
      }
    }
  }
}

######################################################################################################

resource "kubernetes_service" "weatherapi" {
  metadata {
    name = "weatherapi"
  }
  spec {
    selector = {
      App = kubernetes_deployment.weatherapi.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}


