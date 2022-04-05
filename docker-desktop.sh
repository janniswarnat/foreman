#!/usr/bin/env bash

set -ex

kubectl config use-context docker-desktop
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.2/deploy/static/provider/cloud/deploy.yaml
kubectl apply -f ingress-nginx-controller-deployment.yaml
#k3d cluster delete k3s-default
#k3d cluster create --k3s-arg "--disable=traefik@server:*" --volume "$(pwd)/helm-ingress-nginx.yaml:/var/lib/rancher/k3s/server/manifests/helm-ingress-nginx.yaml" --api-port 6550 -p "8000:30000@loadbalancer" -p "9000:31000@loadbalancer" -p "3000:32000@loadbalancer" -p "4505:30001@loadbalancer" -p "4506:30002@loadbalancer" -p "80:80@loadbalancer" -p "443:443@loadbalancer" --agents 2
# ConfigMaps
kubectl apply -f tcp-services-configmap.yaml,dynflow-yml-configmap.yaml,foreman-conf-configmap.yaml,foreman-yaml-configmap.yaml,master-pem-configmap.yaml,master-pub-configmap.yaml,minion-configmap.yaml,minion-pem-configmap.yaml,minion-pub-configmap.yaml,raspberrypi-pub-configmap.yaml,linksmart-black-iot-pub-configmap.yaml,pillar-default-configmap.yaml,pillar-raspberrypi-configmap.yaml,pillar-linksmart-configmap.yaml,pillar-top-configmap.yaml,salt-files-configmap.yaml,salt-yml-configmap.yaml,settings-yml-configmap.yaml,supervisor-conf-configmap.yaml
# Services Foreman
kubectl apply -f redis-cache-service.yaml,redis-tasks-service.yaml,db-service.yaml,app-service.yaml
# Services Salt etc.
kubectl apply -f salt-service.yaml
# PersistentVolumes Foreman
kubectl apply -f db-persistentvolumeclaim.yaml,redis-persistent-persistentvolumeclaim.yaml
# First deployments Foreman
kubectl apply -f db-deployment.yaml,redis-cache-deployment.yaml,redis-tasks-deployment.yaml
# Salt deployments
kubectl apply -f salt-deployment.yaml,salt-minion-deployment.yaml
# Jobs Foreman
kubectl wait --for=condition=available --timeout=300s deployment/db
kubectl apply -f rake-db-create.yaml
kubectl wait --for=condition=complete --timeout=300s job/rake-db-create
kubectl apply -f rake-db-seed.yaml
kubectl wait --for=condition=complete --timeout=300s job/rake-db-seed
kubectl wait --for=condition=available --timeout=300s deployment/salt
# Deploy Foreman
kubectl apply -f app-deployment.yaml,orchestrator-deployment.yaml,worker-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/app
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx
kubectl apply -f ingress-local.yaml

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.2/deploy/static/provider/cloud/deploy.yaml

# get ip address using ifconfig in Ubuntu
#netsh interface portproxy add v4tov4 listenport=4505 listenaddress=0.0.0.0 connectport=4505 connectaddress=192.168.148.113
#netsh interface portproxy add v4tov4 listenport=4506 listenaddress=0.0.0.0 connectport=4506 connectaddress=192.168.148.113