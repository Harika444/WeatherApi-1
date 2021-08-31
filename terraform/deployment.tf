###################################################################################################
################################### K8's SECRETS ##################################################
###################################################################################################

resource "kubernetes_secret" "docker" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-secret-ecrregistry"
    #namespace = "${var.namespace}"
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

###################################################################################################
################################### K8's CONFIGMAP ##############################################
###################################################################################################

resource "kubernetes_config_map" "dev-weatherapi" {
  count = var.namespace == "dev" ? 1 : 0
  metadata {    
    name = "${var.prefix}-${var.project}-dev-configmap-weatherapi"
    namespace = "dev"
  }
  data = {
    TOPIC            = "dev-topic-test"
    EVENT_TYPE       = "dev-event"      
  } 
}

resource "kubernetes_config_map" "prod-weatherapi" {
  count = var.namespace == "prod" ? 1 : 0
  metadata {    
    name = "${var.prefix}-${var.project}-prod-configmap-weatherapi"
    namespace = "prod"
  }
  data = {
    TOPIC            = "prod-topic"
    EVENT_TYPE       = "prod-event"      
  } 
}
###################################################################################################
################################### K8's DEPLOYMENTS ##############################################
###################################################################################################

resource "kubernetes_deployment" "weatherapi" {
  metadata {
    name = "${var.prefix}-${var.project}-${var.namespace}-deployment-weatherapi"
    labels = {
      App = "weatherapi"
    }
    namespace = "${var.namespace}"
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
          name = "${var.prefix}-${var.project}-${var.namespace}-secret-ecrregistry"
        }      
        container {
          image = local.image_name
          name  = "${var.prefix}-${var.project}-${var.namespace}-pod-weatherapi"
          port {
            container_port = 80
          }
          env_from {
            config_map_ref {
              name = "${var.prefix}-${var.project}-${var.namespace}-configmap-weatherapi"
            }
          } 
         /*         
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
          */           
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
    name = "${var.prefix}-${var.project}-${var.namespace}-service-weatherapi"
    namespace = "${var.namespace}"
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
    name = "dev-weatherapi"    
    namespace = "${var.namespace}"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
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
            service_name = "${var.prefix}-${var.project}-${var.namespace}-service-weatherapi"
            service_port = 80
          }          
        }        
      }
    }
  }
}

*/
