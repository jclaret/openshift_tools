# https://red-hat-storage.github.io/ocs-training/training/ocs4/odf4-install-no-ui.html#_installing_the_local_storage_operator
# Label nodes
oc label node rna1-vmaster-0 cluster.ocs.openshift.io/openshift-storage=''
oc label node rna1-vmaster-1 cluster.ocs.openshift.io/openshift-storage=''
oc label node rna1-vmaster-2 cluster.ocs.openshift.io/openshift-storage=''
oc apply -f 01-openshift-local-storage.yaml
oc apply -f 02-LocalVolumeDiscovery.yaml
oc apply -f 03-localvolumeset.yaml
# Enable Console Plugin
# https://access.redhat.com/solutions/6999822
oc patch console.operator cluster -n openshift-storage --type json -p '[{"op": "add", "path": "/spec/plugins", "value": ["odf-console"]}]'
