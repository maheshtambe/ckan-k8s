#!/usr/bin/env bash
export KUBECONFIG="/home/mahesh/.kube/config"

kubectl apply -f ./manifests/rbac.yaml &> /dev/null
kubectl create secret generic ckan-secrets --from-file ./secrets.sh &> /dev/null
deployNode=$(kubectl get nodes --selector=node-role.kubernetes.io/worker -o jsonpath='{ $.items[*].status.addresses[?(@.type=="Hostname")].address }')
deployNodeIp=$(kubectl get no $deployNode -o jsonpath='{ $.status.addresses[?(@.type=="InternalIP")].address }')
#helm delete --timeout 1200 --purge ckan &>/dev/null
helm install -f values.yaml --wait --timeout 1200 --name ckan charts \
	--set nfsInitialize=true \
	--set solrInitialize=true \
	--set minimalPlugins=true \
	--set replicas=1 \
	--set siteUrl=http://$deployNodeIp:31581 \
	--set nodeSelector="kubernetes.io/hostname: "$deployNode