#!/bin/sh
set -o errexit

# XXX: Think on a way to make this not be hardcoded
cluster_name='puppers-ops'

reg_name='kind-registry'
reg_port='5000'

# Create Registry Container unless it already exists
running="$(
  docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true
)"

if [ "${running}" != 'true' ]; then
  docker run -d \
    --restart=always\
    -p "${reg_port}:5000" \
    --name "${reg_name}" \
    registry:2
fi

# Create a cluster with the local registry enabled in containerd
cat <<EOF | kind create cluster --name $cluster_name --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30080
    hostPort: 80
    protocol: TCP
  - containerPort: 30443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
EOF

# Connect registry to the cluster network
docker network connect 'kind' "${reg_name}"

# Tell https://tilt.dev to use the local registry (https://docs.tilt.dev/choosing_clusters.html#discovering-the-registry)
for node in $(kind get nodes --name $cluster_name); do
  kubectl annotate node "${node}" \
    "kind.x-k8s.io/registry=localhost:${reg_port}";
done
