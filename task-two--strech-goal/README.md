# Task Two `Stretch Goal`

Automate the [task-one](../task-one/README.md) using Terraform but with applications read from a json file as below

```json
{
   "applications": [
      {
         "name": "foo",
         "image": "hashicorp/http-echo",
         "args": "-listen=:8081 -text=\"I am foo\"",
         "port": 8081,
         "traffic_weight": "25",
         "replicas": 2
      },
      {
         "name": "bar",
         "image": "hashicorp/http-echo",
         "args": "-listen=:8082 -text=\"I am bar\"",
         "port": 8082,
         "traffic_weight": "25",
         "replicas": 3
      },
      {
         "name": "boom",
         "image": "hashicorp/http-echo",
         "args": "-listen=:8083 -text=\"I am boom\"",
         "port": 8083,
         "traffic_weight": "50",
         "replicas": 4
      }
   ]
}
```

## Solution

### Directory Structure

```bash
.
├── README.md
├── examples
│   ├── applications.json
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── test-traffic-splitting.sh
├── main.tf
├── outputs.tf
└── variables.tf
```

- [README.md](README.md) - Contains instructions for deploying ingress controller,  applications, and virtual server using Terraform
- [examples/applications.json](examples/applications.json) - Contains applications data
- [examples/main.tf](examples/main.tf) - The local module will be called for deploying k8s specific resources
- [examples/outputs.tf](examples/outputs.tf) - Contains module output(i.e urls' to test the traffic splitting based on weight)
- [examples/provider.tf](examples/provider.tf) - Contains kubernetest and helm provider info
- [examples/test-traffic-splitting.sh](examples/test-traffic-splitting.sh) - A shell script to hit endpoint 100 times to test the traffic splitting
- [main.tf](main.tf) - Contains deployments, services, virtualserver and helm ingress controller resources
- [outputs.tf](outputs.tf) - Contains output urls' to test the traffic splitting based on weight
- [variables.tf](variables.tf) - Contains input variables

### Pre-requisite

- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment steps

- Check if minikube is running, if not start it

    ```bash
    # To check status of minikube
    minikube status

    # To start the minikube
    minikube start
    ```

    > Note: _For demonstration purpose, I'm using minikube as local Kubernetes cluster. You can also deploy these configuration in any k8s cluster_

- Initialize a working directory (examples dir) containing Terraform configuration files

    ```bash
    cd examples
    terraform init
    ```

- Update module input values

    ```bash
    # Update external IPs. if using minikube, run `minikube ip` and update the IP in external_ips
    external_ips = ["127.0.0.1"]

    # Any host name of your like, because we are using `curl --resolve` option to pin request to an IP address
    host_name = "example.com"
    ```

- Run below preview the execution plan

    ```bash
    terraform plan
    ```

- Execute the actions proposed in a `terraform plan`

    ```bash
    terraform apply
    ```

    > **Note:** _To skip interactive approval of plan before applying, run `terraform apply --auto-approve`_

- Run the [script](examples/test-traffic-splitting.sh) to verify traffic splitting based on weight

    ```bash
    # Apply execute permission
    chmod +x test-traffic-splitting.sh

    # Run the script
    ./test-traffic-splitting.sh
    ```

- After testing, destroy all remote objects managed by current Terraform configuration

    ```bash
    terraform destroy
    ```

    > **Note:** _To skip interactive approval of proposed destroy changes before destroying, run `terraform destroy --auto-approve`_

- Some useful commands

    ```bash
    # To list deployments
    kubectl get deployments -n <namespace>

    # To list services
    kubectl get services -n <namespace>

    # To list virtual server
    kubectl get virtualserver

    # To get minikube ip
    minikube ip

    # To get url of service if it is of type NodePort
    minikube service <service-name> --url
    ```

### Demo

[![asciicast](https://asciinema.org/a/AXcRwL1nBPCAujyMRIb96ToZX.svg)](https://asciinema.org/a/AXcRwL1nBPCAujyMRIb96ToZX)