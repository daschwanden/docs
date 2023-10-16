#!/bin/bash
# shellcheck disable=SC1091
export USER=user
BASE=$(pwd)
export BASE
export LC_ALL=C.UTF-8
echo "-----------------"
echo "-- Change to install directory"
cd /nephio-installation
echo "-----------------"
echo "-- Waiting for Docker to start"
while (! docker stats --no-stream ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  sleep 1
done
echo "-----------------"
echo "-- Create kind cluster"
kind create cluster --config=kind-config.yaml
echo "-----------------"
echo "-- Setting kubeconfig..."
mkdir /home/user/.kube
cp /root/.kube/config /home/user/.kube/
chown -R user:user /home/user/.kube
echo "-----------------"
echo "-- Gitea installation..."
kubectl create namespace gitea
kubectl create secret generic gitea-postgresql -n gitea \
    --from-literal=postgres-password=secret \
    --from-literal=password=secret
kubectl label secret -n gitea gitea-postgresql app.kubernetes.io/name=postgresql
kubectl label secret -n gitea gitea-postgresql app.kubernetes.io/instance=gitea
kubectl create secret generic git-user-secret -n gitea \
    --type='kubernetes.io/basic-auth' \
    --from-literal=username=nephio \
    --from-literal=password=secret
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages/gitea@v1.0.1
kpt fn render gitea
kpt live init gitea
kpt live apply gitea --reconcile-timeout 15m --output=table
echo "-----------------"
echo "-- Common dependencies..."
echo "---- Network Config Operator"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/network-config@v1.0.1
kpt fn render network-config
kpt live init network-config
kpt live apply network-config --reconcile-timeout=15m --output=table
echo "---- Resource Backend"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/resource-backend@v1.0.1
kpt fn render resource-backend
kpt live init resource-backend
kpt live apply resource-backend --reconcile-timeout=15m --output=table
echo "-----------------"
echo "-- Required Components..."
echo "---- Porch"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/porch-dev@v1.0.1
kpt fn render porch-dev
kpt live init porch-dev
kpt live apply porch-dev --reconcile-timeout=15m --output=table
echo "---- Nephio Controllers"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/nephio-controllers@v1.0.1
kpt fn render nephio-controllers
kpt live init nephio-controllers
kpt live apply nephio-controllers --reconcile-timeout=15m --output=table
echo "---- Management Cluster Gitops Tool"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/configsync@v1.0.1
kpt fn render configsync
kpt live init configsync
kpt live apply configsync --reconcile-timeout=15m --output=table
echo "---- Nephio Stock Repositories"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages.git/nephio-stock-repos@v1.0.1
kpt fn render nephio-stock-repos
kpt live init nephio-stock-repos
kpt live apply nephio-stock-repos --reconcile-timeout=15m --output=table
echo "-----------------"
echo "-- Provisioning Cluster API..."
echo "---- Cert Manager"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages/cert-manager@v1.0.1
kpt fn render cert-manager
kpt live init cert-manager
kpt live apply cert-manager --reconcile-timeout 15m --output=table
echo "---- Cluster API"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages/cluster-capi@v1.0.1
kpt fn render cluster-capi
kpt live init cluster-capi
kpt live apply cluster-capi --reconcile-timeout 15m --output=table
echo "---- Cluster API infrastructure docker"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages/cluster-capi-infrastructure-docker@v1.0.1
kpt fn render cluster-capi-infrastructure-docker
kpt live init cluster-capi-infrastructure-docker
kpt live apply cluster-capi-infrastructure-docker --reconcile-timeout 15m --output=table
echo "---- Cluster API kind docker templates"
kpt pkg get --for-deployment https://github.com/nephio-project/nephio-example-packages/cluster-capi-kind-docker-templates@v1.0.1
kpt fn render cluster-capi-kind-docker-templates
kpt live init cluster-capi-kind-docker-templates
kpt live apply cluster-capi-kind-docker-templates --reconcile-timeout 15m --output=table
echo "-----------------"
cd "$BASE" || exit
echo "demo installation done"
echo "-----------------"
