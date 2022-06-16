module "terraform-module-k8s-bg-dply" {
    source = "../"
    apps_json_file_path = "applications.json"
    external_ips = ["<ip-address>"]
    host_name = "<host-name>"
}