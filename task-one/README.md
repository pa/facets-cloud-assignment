# Task One

Deployment of Blue - Green application using Kubernetes Configuration files

- Run minikube
- Create a `blue-app` Deployment and expose it via an internal Service with the following specification

    ```bash
    Image: hashicorp/http-echo
    Arguemnts: -listen=:8080 -text="I am blue"
    Replicas: 2
    Port: 8080
    ```

- Create `green-app` Deployment and expose it via an internal Service with the following specification

    ```bash
    Image: hashicorp/http-echo
    Arguemnts: -listen=:8081 -text="I am green"
    Replicas: 3
    Port: 8081
    ```

- Use nginx ingress controller to expose an http endpoint which routes `75%` of the calls to blue appand `25%` of the calls to green-app

## Solution

### Directory Struture

```bash
.
├── README.md
├── deployments
│   ├── blue-app.yml
│   └── green-app.yml
├── ingress
│   ├── ingress-blue-app.yml
│   └── ingress-green-app-canary.yml
├── services
│   ├── blue-app-svc.yml
│   └── green-app-svc.yml
└── test-canary-release.sh
```

- [README.md](README.md) - Contains blue-green application deployment instructions
- [deployments/blue-app.yml](deployments/blue-app.yml) - Contains a deployment which uses `hashicorp/http-echo` container image with args `-listen=:8080 -text="I am blue"`
- [deployments/green-app.yml](deployments/green-app.yml) - Contains a deployment which uses `hashicorp/http-echo` container image with args `-listen=:8081 -text="I am green"`
- [services/blue-app-svc.yml](services/blue-app-svc.yml) - Contains a `ClusterIP` service for `blue-app`
- [services/green-app-svc.yml](services/green-app-svc.yml) - Contains a `ClusterIP` service for `green-app`
- [ingress/ingress-blue-app.yml](ingress/ingress-blue-app.yml) - Contains path based route to `blue-app` backend service with [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [ingress/ingress-green-app-canary.yml](ingress/ingress-green-app-canary.yml) - Contains weight based path routing to `green-app` backend service using `nginx.ingress.kubernetes.io/canary-weight` annotation with [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [test-canary-release.sh](test-canary-release.sh) - It is a shell script to test the canaray release of the application. This script will curl minikube ip 10 times to see if the traffics are routed to services based on the canary configuration (i.e 25% traffic to green app and 75% to blue app).


deployments/blue-app.yml

### Pre-requisite

- Install [minikube](https://minikube.sigs.k8s.io/docs/start/)
- Install [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

### Deployment steps

- Check if minikube is running, if not start it

    ```bash
    # To check status of minikube
    minikube status

    # To start the minikube
    minikube start
    ```

- Deploy blue and green app

    ```bash
    kubectl apply -f deployments/
    ```

- Deploy blue and green app services

    ```bash
    kubectl apply -f services/
    ```

- Deploy blue and green app ingresses

    ```bash
    kubectl apply -f ingress/
    ```

- Run the [script](test-canary-release.sh) to verify blue and green app deployment

    ```bash
    # Apply execute permission
    chmod +x test-canary-release.sh

    # Run the script
    ./test-canary-release.sh
    ```

- Some useful commands to list deployment, services, ingress and node

    ```bash
    # To list deployments
    kubectl get deployments -n <namespace>

    # To list services
    kubectl get services -n <namespace>

    # To list ingress
    kubectl get ingress -n <namesapce>

    # List nodes
    kubectl get nodes

    # To get minikube ip
    minikube ip

    # To get url of service if it is of type NodePort
    minikube service <service-name> --url
    ```
