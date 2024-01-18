$ git clone https://github.com/openshift/sriov-network-operator.git
$ git checkout release-4.12
$ git log --pretty=format:"%h - %an, %ar : %s" 17eb394^..5d352e2 
$ lspci -nnvv
$ oc get node worker-{0..1} -o yaml | grep -i sriovnetwork.openshift.io/state:
$ oc -n openshift-sriov-network-operator get sriovnetworknodestate worker-{0..1} -o yaml | grep -i syncStatus 
$ oc adm upgrade --to='4.12.45'
$ oc get node <sriovcapablenode> -o yaml | yq -e '.status.capacity'
$ ssh core@<node> 'sudo cat /sys/class/net/ens3f0/device/sriov_numvfs'
$ ssh core@<node> 'sudo cat /sys/class/net/ens3f1/device/sriov_numvfs'
$ ethtool -i ens3fxxx (look for bus-info)
