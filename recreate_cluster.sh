#!/usr/bin/env bash

k3d cluster delete k3s-default
k3d cluster create --api-port 6550 -p "8000:30000@loadbalancer" -p "9000:31000@loadbalancer" -p "3000:32000@loadbalancer" -p "4505:30001@loadbalancer" -p "4506:30002@loadbalancer" --agents 2
# ConfigMaps
kubectl apply -f dynflow-yml-configmap.yaml,foreman-conf-configmap.yaml,foreman-yaml-configmap.yaml,master-pem-configmap.yaml,master-pub-configmap.yaml,minion-configmap.yaml,minion-pem-configmap.yaml,minion-pub-configmap.yaml,raspberrypi-pub-configmap.yaml,pillar-default-configmap.yaml,pillar-raspberrypi-configmap.yaml,pillar-top-configmap.yaml,salt-files-configmap.yaml,salt-yml-configmap.yaml,settings-yml-configmap.yaml,supervisor-conf-configmap.yaml
# Services
kubectl apply -f redis-cache-service.yaml,redis-tasks-service.yaml,db-service.yaml,salt-service.yaml,app-service.yaml
# PersistentVolumes
kubectl apply -f db-persistentvolumeclaim.yaml,redis-persistent-persistentvolumeclaim.yaml
# First deployments
kubectl apply -f db-deployment.yaml,redis-cache-deployment.yaml,redis-tasks-deployment.yaml,salt-deployment.yaml,salt-minion-deployment.yaml
# Jobs
kubectl apply -f rake-db-create.yaml,rake-db-seed.yaml
# Last deployments
# kubectl apply -f app-deployment.yaml,orchestrator-deployment.yaml,worker-deployment.yaml

#netsh interface portproxy add v4tov4 listenport=4505 listenaddress=0.0.0.0 connectport=4505 connectaddress=172.24.133.75
#netsh interface portproxy add v4tov4 listenport=4506 listenaddress=0.0.0.0 connectport=4506 connectaddress=172.24.133.75