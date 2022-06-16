module "terraform-module-k8s-bg-dply" {
    source = "../"
    apps_json_file_path = "applications.json"
    external_ips = ["192.168.64.5"]
    host_name = "example.com"
}