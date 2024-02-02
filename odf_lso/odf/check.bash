# Approve Install plan
oc patch installplan install-dq68d --namespace openshift-storage --type merge --patch '{"spec":{"approved":true}}'
# Noobaa issues # Noobaa issues https://www.noobaa.io/noobaa-crd.html
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
TOOLS_POD=$(oc get pods -n openshift-storage -l app=rook-ceph-tools -o name)
oc rsh -n openshift-storage $TOOLS_POD
ceph status
ceph osd tree
ceph health detail
ceph crash ls
