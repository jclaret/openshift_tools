#!/bin/bash

set -e

# Create additional network using kcli
kcli create network -c 192.168.1.0/24 --nodhcp --domain multus.lab multus

# Update vm using kcli
# Example for master node
kcli update vm hub-master0 -P nets="[{\"name\":\"5gdeploymentlab\"},{\"name\":\"multus\"}]"

# Create new project using oc
oc new-project jordi-multus

# Create NetworkAttachmentDefinition using kubectl
cat <<EOF | kubectl create -f -
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf
spec:
  config: '{
    "cniVersion": "0.3.0",
    "type": "macvlan",
    "master": "enp8s0",
    "mode": "bridge",
    "ipam": {
      "type": "host-local",
      "subnet": "192.168.1.0/24",
      "rangeStart": "192.168.1.200",
      "rangeEnd": "192.168.1.216",
      "routes": [
        { "dst": "0.0.0.0/0" }
      ],
      "gateway": "192.168.1.1"
    }
  }'
EOF

# Check NetworkAttachmentDefinition using oc
oc get network-attachment-definitions -n jordi-multus

# Create Pod using kubectl
cat <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: samplepod
  annotations:
    k8s.v1.cni.cncf.io/networks: macvlan-conf
spec:
  containers:
  - name: samplepod
    command: ["/bin/bash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: ubi8/ubi
EOF

# Describe Pod using kubectl
kubectl describe pod samplepod
