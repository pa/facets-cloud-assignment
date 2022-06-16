locals {
  # get applications json
  applications = jsondecode(file(var.apps_json_file_path)).applications
}

# Create nginx ingress controller with loadbalancer service
resource "helm_release" "nic" {
  name = "nginx-ingress-controller"
  repository = "https://helm.nginx.com/stable"
  chart = "nginx-ingress"
  namespace = "nginx-ingress"
  create_namespace = true

  set {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  dynamic "set" {
    for_each = var.external_ips
    content {
      name = "controller.service.externalIPs[${set.key}]"
      value = set.value
    }
  }
}


# Create kubernetes deployments based on json input
resource "kubernetes_deployment" "apps_deployment" {
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
resource "kubernetes_service_v1" "apps_svcs" {
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

# Create ingress controller virtual server to split traffic based on weight
resource "kubernetes_manifest" "virtual_server" {
  manifest = {
    apiVersion = "k8s.nginx.org/v1"
    kind = "VirtualServer"
    metadata = {
      name      = "traffic-splitting-vs"
      namespace = "default"
    }

    spec = {
      host = var.host_name
      upstreams = [
        for app in local.applications : {
          name = format("%s-upstream", app.name)
          service = format("%s-svc", app.name)
          port = app.port
        }
      ]
      routes = [
        {
          path = "/"
          splits = [
            for app in local.applications : {
              "weight" = app.traffic_weight
              action = {
                "pass" = format("%s-upstream", app.name)
              }
            }
          ]
        }
      ]
    }
  }
}
