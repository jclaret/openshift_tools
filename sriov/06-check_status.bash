oc -n openshift-sriov-network-operator get sriovnetworknodestate worker-{0..1} -o yaml | grep -i syncStatus
oc get node worker-{0..1} -o yaml | grep -i sriovnetwork.openshift.io/state:
oc get node worker-{0..1} -o yaml | grep -A10 'capacity'

