# kcli update vm rna1-vmaster-{0..2} -P numcpus=64 -P memory=135168
oc create -f 01-odf-operator.yaml
oc create -f 02-StorageCluster.yaml
oc create -f 03-rbd-pvc.yaml
oc create -f 04-cephfs-pvc.yaml
