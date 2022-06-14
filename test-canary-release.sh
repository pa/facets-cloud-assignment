#! /bin/bash

MINICUBE_IP=$(minikube ip)

for i in {1..10};
do
    curl $MINICUBE_IP
done