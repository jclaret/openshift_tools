oc create -f 01-odf-operator.yaml
oc create -f 02-StorageCluster.yaml
oc create -f 03-rbd-pvc.yaml
oc create -f 04-cephfs-pvc.yaml
