###################################################################################################
################################### K8's SECRETS ##################################################
###################################################################################################

resource "kubernetes_secret" "docker" {
  metadata {
    name = "ecr-registry"
    namespace = "prod"
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

/*
resource "kubernetes_secret" "sql_server" {
  metadata {
    name = "sql-secret"
  }
  data = {
    sql-root-username = "${data.terraform_remote_state.mssql.outputs.db_instance_username}"
    sql-root-password = "${var.sql_password}"
  }  
}
*/
###################################################################################################
################################### K8's CONFIGMAP ##############################################
###################################################################################################

resource "kubernetes_config_map" "weatherapi" {
  metadata {
    name = "weatherapi-confimap"
    namespace = "prod"
  }
  data = {
    topic            = "example-topic"
    event-type       = "example-event"  
    #db_url           = "${data.terraform_remote_state.mssql.outputs.db_instance_endpoint}"
  } 
}
###################################################################################################
################################### K8's DEPLOYMENTS ##############################################
###################################################################################################

resource "kubernetes_deployment" "weatherapi" {
  metadata {
    name = "weatherapi"
    labels = {
      App = "weatherapi"
    }
    namespace = "prod"
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
          name = "ecr-registry"
        }      
        container {
          image = local.image_name
          name  = "weatherapi"
          port {
            container_port = 80
          }
          /*
          env {
            name = "SQL_USERNAME"
            value_from {
                secret_key_ref {
                  name = data.kubernetes_secret.sql-server.metadata.0.name
                  key = "sql-root-username"
                }
            }
          }
          env {            
            name = "SQL_PASSWORD"
            value_from {
                secret_key_ref {
                  name = data.kubernetes_secret.sql-server.metadata.0.name
                  key = "sql-root-password"
                }
            }
          }
          env {
            name = "SQL_DB_URL"
            value_from {
                config_map_key_ref {
                  name = kubernetes_config_map.weatherapi.metadata.0.name
                  key = "db_url"
                }
            }
          }
          */
          env {            
            name = "TOPIC"
            value_from {
                config_map_key_ref {
                  name = kubernetes_config_map.weatherapi.metadata.0.name
                  key = "topic"
                }
            }
          }
          env {            
            name = "EVENT_TYPE"
            value_from {
                config_map_key_ref {
                  name = kubernetes_config_map.weatherapi.metadata.0.name
                  key = "event-type"
                }
            }
          }           
        }
      }
    }
  }
}

###################################################################################################
################################### K8's SERVICE ##################################################
###################################################################################################

resource "kubernetes_service" "weatherapi" {
  metadata {
    name = "weatherapi"
    namespace = "prod"
  }
  spec {
    selector = {
      App = kubernetes_deployment.weatherapi.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

###################################################################################################
################################### K8's INGRESS ##################################################
###################################################################################################
resource "kubernetes_ingress" "weather_api_ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "prod-weatherapi"
    namespace = "prod"
    annotations = {
      "kubernetes.io/ingress.class" = "dev-alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/weatherforecast"
          backend {
            service_name = "weatherapi"
            service_port = 80
          }          
        }        
      }
    }
  }
}


