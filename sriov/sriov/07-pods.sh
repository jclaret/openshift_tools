echo "create vfio-pci pods"
cat <<'EOF'>.sriovpoda.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sriovpoda
  namespace: sriov-testing
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
	{
		"name": "sriov-net-ens1f0-vfiopci",
		"mac": "20:04:0f:f1:88:01",
		"ips": ["192.168.10.10/24", "2001::10/64"]
	}
]'
spec:
  containers:
  - name: sample-container
    image: registry.redhat.io/rhel8/support-tools
    imagePullPolicy: IfNotPresent
    command: ["sleep", "infinity"]
EOF
oc apply -f .sriovpoda.yaml

cat <<'EOF'>.sriovpodb.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sriovpodb
  namespace: sriov-testing
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
        {
                "name": "sriov-net-ens1f0-vfiopci",
                "mac": "20:04:0f:f1:88:02",
                "ips": ["192.168.10.11/24", "2001::11/64"]
        }
]'
spec:
  containers:
  - name: sample-container
    image: registry.redhat.io/rhel8/support-tools
    imagePullPolicy: IfNotPresent
    command: ["sleep", "infinity"]
EOF
oc apply -f .sriovpodb.yaml

echo "create netdev pods"
cat <<'EOF'>.sriovpodc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sriovpodc
  namespace: sriov-testing
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
        {
                "name": "sriov-net-ens1f1-netdev",
                "ips": ["192.168.10.12/24", "2001::12/64"]
        }
]'
spec:
  containers:
  - name: sample-container
    image: registry.redhat.io/rhel8/support-tools
    imagePullPolicy: IfNotPresent
    command: ["sleep", "infinity"]
EOF
oc apply -f .sriovpodc.yaml	

cat <<'EOF'>.sriovpodd.yaml
apiVersion: v1
kind: Pod
metadata:
  name: sriovpodd
  namespace: sriov-testing
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
        {
                "name": "sriov-net-ens1f1-netdev",
                "ips": ["192.168.10.13/24", "2001::13/64"]
        }
]'
spec:
  containers:
  - name: sample-container
    image: registry.redhat.io/rhel8/support-tools
    imagePullPolicy: IfNotPresent
    command: ["sleep", "infinity"]
EOF
oc apply -f .sriovpodd.yaml
