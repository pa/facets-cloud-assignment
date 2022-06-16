variable "apps_json_file_path" {
  description = "Json file path which contains application specific configs"
}

variable "external_ips" {
  description = "external ips for ingress controller service"
}

variable "host_name" {
  description = "host name for test the traffic splits"
}