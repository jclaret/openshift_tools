oc delete sriovnetwork --all -n openshift-sriov-network-operator
oc delete sriovnodenetworkpolicy --all -n openshift-sriov-network-operator
oc delete sub --all -n openshift-sriov-network-operator
oc delete csv --all -n openshift-sriov-network-operator
oc delete ds --all -n openshift-sriov-network-operator
oc delete crd sriovibnetworks.sriovnetwork.openshift.io sriovnetworknodepolicies.sriovnetwork.openshift.io sriovnetworknodestates.sriovnetwork.openshift.io sriovnetworkpoolconfigs.sriovnetwork.openshift.io sriovnetworks.sriovnetwork.openshift.io sriovoperatorconfigs.sriovnetwork.openshift.io
oc delete mutatingwebhookconfigurations network-resources-injector-config
oc delete MutatingWebhookConfiguration sriov-operator-webhook-config
oc delete ValidatingWebhookConfiguration sriov-operator-webhook-config
 oc delete namespace openshift-sriov-network-operator
