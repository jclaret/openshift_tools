for node in $(oc get nodes -o name | grep cloud); do oc label ${node} sriov="true"; done
oc patch sriovoperatorconfig default --type=json \
  -n openshift-sriov-network-operator \
  --patch '[{"op": "replace","path": "/spec/configDaemonNodeSelector","value": {sriov: "true"}}]'
