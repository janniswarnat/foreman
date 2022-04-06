#!/usr/bin/env bash

set -ex

kubectl config use-context havana
# ConfigMaps
kubectl apply -f dynflow-yml-configmap.yaml,foreman-conf-configmap.yaml,foreman-yaml-configmap.yaml,master-pem-configmap.yaml,master-pub-configmap.yaml,minion-configmap.yaml,minion-pem-configmap.yaml,minion-pub-configmap.yaml,raspberrypi-pub-configmap.yaml,linksmart-black-iot-pub-configmap.yaml,pillar-default-configmap.yaml,pillar-raspberrypi-configmap.yaml,pillar-linksmart-configmap.yaml,pillar-top-configmap.yaml,salt-files-configmap.yaml,salt-yml-configmap.yaml,settings-yml-configmap.yaml,supervisor-conf-configmap.yaml
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
kubectl apply -f ingress.yaml
