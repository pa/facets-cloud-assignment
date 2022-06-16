#! /bin/bash

# Set Ingress Controller IP that is minikube IP
IC_IP=$(minikube ip)
IC_HTTP_PORT=80

# Hit the endpoint 100 times to verify traffic splitting
for i in {1..100};
do
    curl --resolve example.com:$IC_HTTP_PORT:$IC_IP http://example.com:$IC_HTTP_PORT/
done
