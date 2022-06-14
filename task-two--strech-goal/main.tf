locals {
  # get applications json
  applications = jsondecode(file(var.apps_json_file_path)).applications
}

# Create kubernetes deployments based on json input
resource "kubernetes_deployment" "default" {
  for_each = { for app in local.applications : app.name => app }

  metadata {
      name = format("%s-deployment", each.value.name)
      labels = {
          app = each.value.name
      }
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = each.value.name
      }
    }

    template {
      metadata {
        labels = {
          app = each.value.name
        }
      }

      spec {
        container {
          image = each.value.image
          name = format("%s-container", each.value.name)
          args = concat([element(split(" ", each.value.args), 0)], [element(regex(" (.*)", each.value.args), 0)])
        }
      }
    }
  }
}

# Create kubernetes services based on json input
resource "kubernetes_service_v1" "default" {
  for_each = { for app in local.applications : app.name => app }

  metadata {
    name = format("%s-svc", each.value.name)
  }
  spec {
    selector = {
      app = each.value.name
    }

    port {
      name = format("%s-port", each.value.name)
      port        = each.value.port
      target_port = each.value.port
    }

    type = "ClusterIP"
  }
}

# Create kubernetes ingress resource based in json input
resource "kubernetes_ingress_v1" "default" {
  for_each = { for app in local.applications : app.name => app }

  metadata {
    name = format("%s-ingress", each.value.name)
    annotations = {
      "nginx.ingress.kubernetes.io/canary" = "true"
      "nginx.ingress.kubernetes.io/canary-weight" = each.value.traffic_weight
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = format("%s-svc", each.value.name)
              port {
                number = each.value.port
              }
            }
          }
        }
      }
    }
  }
}




