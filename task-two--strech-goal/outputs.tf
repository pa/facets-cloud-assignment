output "url_to_test"{
    value = [ for external_ip in var.external_ips : format("curl --resolve ${var.host_name}:80:%s http://${var.host_name}:80/", external_ip) ]
}