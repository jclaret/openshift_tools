
watch "oc get sriovnetworknodestates -n openshift-sriov-network-operator rna1-master-0.rna1.cloud.lab.eng.bos.redhat.com -o jsonpath={.status.syncStatus} && echo -e && oc get sriovnetworknodestates -n openshift-sriov-network-operator rna1-master-1.rna1.cloud.lab.eng.bos.redhat.com -o jsonpath={.status.syncStatus} && echo -e  && oc get sriovnetworknodestates -n openshift-sriov-network-operator rna1-master-2.rna1.cloud.lab.eng.bos.redhat.com -o jsonpath={.status.syncStatus}"
