oc -n openshift-storage wait lvmcluster odf-lvmcluster --for=jsonpath='{.status.state}'=Ready --timeout=900s
oc patch storageclass lvms-vg1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
