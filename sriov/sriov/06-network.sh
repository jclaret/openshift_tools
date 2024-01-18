echo "create new sriov-testing project"
oc new-project sriov-testing
oc project sriov-testing

echo "create network ens1f0 vfio-pci"
cat <<'EOF'>.sriovnetwork-ens1f0.yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetwork
metadata:
  name: sriov-net-ens1f0-vfiopci
  namespace: openshift-sriov-network-operator
spec:
  networkNamespace: sriov-testing
  ipam: '{ "type": "static" }'
  vlan: 309
  resourceName: sriovens1f0vf0
  trust: "on"
  capabilities: '{ "mac": true, "ips": true }'
EOF
oc apply -f .sriovnetwork-ens1f0.yaml

echo "create network ens1f1 netdevice"
cat <<'EOF'>.sriovnetwork-ens1f1.yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetwork
metadata:
  name: sriov-net-ens1f1-netdev
  namespace: openshift-sriov-network-operator
spec:
  networkNamespace: sriov-testing
  ipam: '{ "type": "static" }'
  vlan: 309
  resourceName: sriovens1f0vf1
  trust: "on"
  capabilities: '{ "ips": true }'
EOF
oc apply -f .sriovnetwork-ens1f1.yaml

