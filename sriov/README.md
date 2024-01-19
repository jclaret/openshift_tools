# Quickstart Guide

```bash
```
## Environment

* Openshift cluster running on baremetal. It will use worker-0 and worker-1 to configure the SR-IOV NICs

```bash
$ export KUBECONFIG="/home/jcl/cnf-build/auth/kubeconfig
$ oc get nodes
NAME           STATUS   ROLES                  AGE   VERSION
ctrl-plane-0   Ready    control-plane,master   28h   v1.25.14+a52e8df
ctrl-plane-1   Ready    control-plane,master   29h   v1.25.14+a52e8df
ctrl-plane-2   Ready    control-plane,master   29h   v1.25.14+a52e8df
worker-0       Ready    worker                 28h   v1.25.14+a52e8df
worker-1       Ready    worker                 28h   v1.25.14+a52e8df
$ oc get clusterversion
NAME      VERSION   AVAILABLE   PROGRESSING   SINCE   STATUS
version   4.12.45   True        False         3h16m   Cluster version is 4.12.45
```

* SR-IOV is enabled in the BIOS. For an iDRAC, navigate to the following

```bash
System Setup -> System BIOS -> Integrated Devices -> SR-IOV Global Enable
```
or 

```bash
System Setup -> Device Settings -> [Choose a NIC port] -> Device Level Configuration -> Virtualization Mode (SR-IOV) 
```

* Openshift cluster s equipped with SR-IOV compatible Network Interface card, "Intel Corporation Ethernet Controller XXV710". See compatible models [here](https://github.com/k8snetworkplumbingwg/sriov-network-operator/blob/master/doc/supported-hardware.md).

```bash
$ oc debug node/worker-0 -- chroot /host lspci | grep -i ethernet
Temporary namespace openshift-debug-z85qk is created for debugging node...
Starting pod/worker-0-debug ...
To use host binaries, run `chroot /host`

19:00.0 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]
19:00.1 Ethernet controller: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]
3b:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
3b:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
60:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
60:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
64:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
64:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
86:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
86:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
b1:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
b1:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
b5:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)
b5:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 Intel(R) FPGA Programmable Acceleration Card N3000 for Networking (rev 02)

Removing debug pod ...
Temporary namespace openshift-debug-z85qk was removed.
```
* Verify component has **Single Root I/O Virtualization (SR-IOV)** capabilities and **VFs** and the NIC name

```bash
$ oc debug node/worker-0 
sh-4.4# chroot /host
sh-4.4# lspci -nnvvs 86:00.0
...
86:00.0 Ethernet controller [0200]: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 [8086:158b] (rev 02)
	Subsystem: Intel Corporation Ethernet 25G 2P XXV710 Adapter [8086:0009]
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	Interrupt: pin A routed to IRQ 861
	NUMA node: 1
	IOMMU group: 111
...
	Capabilities: [160 v1] Single Root I/O Virtualization (SR-IOV)
		IOVCap:	Migration-, Interrupt Message Number: 000
		IOVCtl:	Enable+ Migration- Interrupt- MSE+ ARIHierarchy+
		IOVSta:	Migration-
		Initial VFs: 64, Total VFs: 64, Number of VFs: 5, Function Dependency Link: 00
		VF offset: 16, stride: 1, Device ID: 154c
		Supported Page Size: 00000553, System Page Size: 00000001
		Region 0: Memory at 00000000d6400000 (64-bit, prefetchable)
		Region 3: Memory at 00000000d6910000 (64-bit, prefetchable)
		VF Migration: offset: 00000000, BIR: 0
...
	Kernel driver in use: i40e
	Kernel modules: i40e
...

sh-4.4# ip a | grep ens
2: ens1f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master ovs-system state UP group default qlen 1000
3: ens1f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
5: ens3f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
6: ens3f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
8: ens7f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group default qlen 1000
10: ens7f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
14: ens4f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
15: ens4f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group default qlen 1000

sh-4.4# ethtool -i ens7f0
ethtool -i ens7f0 
driver: i40e
version: 4.18.0-372.82.1.el8_6.x86_64
firmware-version: 9.20 0x8000d960 22.0.9
expansion-rom-version: 
bus-info: 0000:86:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

sh-4.4# cat /sys/class/net/ens*f*/device/sriov_numvfs
0
0
0
0
0
0
0
0

sh-4.4# ls -l /sys/class/net/ens*f*/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens1f0/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens1f1/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens3f0/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens3f1/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens4f0/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 19 11:44 /sys/class/net/ens4f1/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 19 11:44 /sys/class/net/ens7f0/device/sriov_numvfs
-rw-r--r--. 1 root root 4096 Jan 18 20:15 /sys/class/net/ens7f1/device/sriov_numvfs

```

NOTE: lshw is a better command to check this stuff, but it is not part of the RHCoreOS

## SR-IOV Operator Installation

* Deploy the operator and label nodes

```bash
$ oc create -f 01-sriov.yaml
namespace/openshift-sriov-network-operator created
operatorgroup.operators.coreos.com/sriov-network-operators created
subscription.operators.coreos.com/sriov-network-operator-subscription created

$ bash 02-label-nodes.bash
node/worker-1 not labeled
node/worker-0 not labeled
```

* Check the status of **SriovNetworkNodeState** CRs to find SRIOV devices

```bash
$ oc get sriovnetworknodestates -n openshift-sriov-network-operator
NAME       AGE
worker-0   108s
worker-1   108s

$ oc get sriovnetworknodestates -n openshift-sriov-network-operator worker-0 -o yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetworkNodeState
metadata:
  creationTimestamp: "2024-01-19T11:38:30Z"
  generation: 1
  name: worker-0
  namespace: openshift-sriov-network-operator
  ownerReferences:
  - apiVersion: sriovnetwork.openshift.io/v1
    blockOwnerDeletion: true
    controller: true
    kind: SriovNetworkNodePolicy
    name: default
    uid: b23d2a8a-3dce-4278-bb33-d6fd7609911f
  resourceVersion: "980992"
  uid: c13e2936-9317-4ace-aa7e-4e06bf39fd4f
spec:
  dpConfigVersion: "980722"
status:
  interfaces:
...
  - deviceID: 158b
    driver: i40e
    linkSpeed: 25000 Mb/s
    linkType: ETH
    mac: 40:a6:b7:63:28:c0
    mtu: 1500
    name: ens7f0
    pciAddress: 0000:86:00.0
    totalvfs: 64
    vendor: "8086"
  - deviceID: 158b
    driver: i40e
    linkSpeed: 25000 Mb/s
    linkType: ETH
    mac: 40:a6:b7:63:28:c1
    mtu: 1500
    name: ens7f1
    pciAddress: 0000:86:00.1
    totalvfs: 64
    vendor: "8086"
...
```

## Configuration

* Create a **SriovNetworkNodePolicy** and **SriovNetwork**.

```yaml
$ cat 03-create-policy.yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetworkNodePolicy
metadata:
  name: policy-example
  namespace: openshift-sriov-network-operator
spec:
  nodeSelector:
    feature.node.kubernetes.io/network-sriov.capable: "true"
  resourceName: intelnics
  priority: 99
  mtu: 9000
  numVfs: 5
  nicSelector:
      deviceID: 158b
      rootDevices:
      - 0000:86:00.0
      vendor: "8086"
  deviceType: netdevice

$ oc create -f 03-create-policy.yaml
sriovnetworknodepolicy.sriovnetwork.openshift.io/policy-example created

$ oc get SriovNetworkNodePolicy
NAME             AGE
default          18m
policy-example   12s
```

After applying **SriovNetworkNodePolicy** policy-example, check the status of **SriovNetworkNodeState** again, you should be able to see the NIC has been configured

```bash
$ oc get sriovnetworknodestates -n openshift-sriov-network-operator worker-0 -o yaml
...
spec:
  dpConfigVersion: 6885fe3a2666f0979fab16cac6088fb8
  interfaces:
  - mtu: 9000
    name: ens7f0
    numVfs: 5
    pciAddress: 0000:86:00.0
    vfGroups:
    - deviceType: netdevice
      mtu: 9000
      policyName: policy-example
      resourceName: intelnics
      vfRange: 0-4
...
status:
  - Vfs:
    - deviceID: 154c
      driver: iavf
      mac: ee:49:20:db:89:dd
      mtu: 9000
      name: ens7f0v0
      pciAddress: 0000:86:02.0
      vendor: "8086"
      vfID: 0
    - deviceID: 154c
      driver: iavf
      mac: 56:72:d2:1f:81:54
      mtu: 9000
      name: ens7f0v1
      pciAddress: 0000:86:02.1
      vendor: "8086"
      vfID: 1
    - deviceID: 154c
      driver: iavf
      mac: 12:e4:d0:a1:2c:a6
      mtu: 9000
      name: ens7f0v2
      pciAddress: 0000:86:02.2
      vendor: "8086"
      vfID: 2
    - deviceID: 154c
      driver: iavf
      mac: 22:89:3e:b7:d6:59
      mtu: 9000
      name: ens7f0v3
      pciAddress: 0000:86:02.3
      vendor: "8086"
      vfID: 3
    - deviceID: 154c
      driver: iavf
      mac: ba:df:2d:85:2d:35
      mtu: 9000
      name: ens7f0v4
      pciAddress: 0000:86:02.4
      vendor: "8086"
      vfID: 4

$ oc debug node/worker-0
$ cat /sys/class/net/ens7f0/device/sriov_numvfs
5

$ lspci | grep 86   
86:00.0 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
86:00.1 Ethernet controller: Intel Corporation Ethernet Controller XXV710 for 25GbE SFP28 (rev 02)
86:02.0 Ethernet controller: Intel Corporation Ethernet Virtual Function 700 Series (rev 02)
86:02.1 Ethernet controller: Intel Corporation Ethernet Virtual Function 700 Series (rev 02)
86:02.2 Ethernet controller: Intel Corporation Ethernet Virtual Function 700 Series (rev 02)
86:02.3 Ethernet controller: Intel Corporation Ethernet Virtual Function 700 Series (rev 02)
86:02.4 Ethernet controller: Intel Corporation Ethernet Virtual Function 700 Series (rev 02)

$ ip a| grep ens7f0  
8: ens7f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc mq state UP group default qlen 1000
107: ens7f0v4: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN group default qlen 1000
108: ens7f0v1: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN group default qlen 1000
109: ens7f0v0: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN group default qlen 1000
110: ens7f0v2: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN group default qlen 1000
111: ens7f0v3: <BROADCAST,MULTICAST> mtu 9000 qdisc noop state DOWN group default qlen 1000

$ lspci -nnvvs 86:02.0
86:02.0 Ethernet controller [0200]: Intel Corporation Ethernet Virtual Function 700 Series [8086:154c] (rev 02)
	Subsystem: Intel Corporation Device [8086:0000]
	Control: I/O- Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0
	NUMA node: 1
	IOMMU group: 168
...
	Kernel driver in use: iavf
	Kernel modules: iavf
...
```

Also, check if resource name 'intelnics' is reported by the nodes

```bash
$ oc get nodes worker-0 -o yaml
...
  allocatable:
    cpu: 95500m
    ephemeral-storage: "430036622237"
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 195476484Ki
    openshift.io/intelnics: "5"  <<< 
    pods: "250"
...
```

* Create a **SriovNetwork** which refers to the resourceName in **SriovNetworkNodePolicy** and **NetworkAttachmentDefinition** CR will be created by operator with the same name and namespace.

```yaml
$ cat 04-create-sriovnetwork.yaml
apiVersion: sriovnetwork.openshift.io/v1
kind: SriovNetwork
metadata:
  name: example-sriovnetwork
  namespace: sriov-network-operator
spec:
  ipam: | 
    {
      "type": "host-local",
      "subnet": "10.56.217.0/24",
      "rangeStart": "10.56.217.171",
      "rangeEnd": "10.56.217.181",
      "routes": [{
        "dst": "0.0.0.0/0"
      }],
      "gateway": "10.56.217.1"
    }
  vlan: 0
  resourceName: intelnics

$ oc create -f 04-create-sriovnetwork.yaml
sriovnetwork.sriovnetwork.openshift.io/sriovnetwork-example created

$ oc get SriovNetwork -n openshift-sriov-network-operator
NAME                   AGE
sriovnetwork-example   43s

$ oc get network-attachment-definitions -n sriov-example
NAME                   AGE
sriovnetwork-example   2m49s

$ oc get network-attachment-definitions -n sriov-example -o yaml
apiVersion: v1
items:
- apiVersion: k8s.cni.cncf.io/v1
  kind: NetworkAttachmentDefinition
  metadata:
    annotations:
      k8s.v1.cni.cncf.io/resourceName: openshift.io/intelnics
    name: sriovnetwork-example
    namespace: sriov-example
  spec:
    config: '{ "cniVersion":"0.3.1", "name":"sriovnetwork-example","type":"sriov","vlan":0,"vlanQoS":0,"ipam":{"type":"host-local","subnet":"10.56.217.0/24","rangeStart":"10.56.217.171","rangeEnd":"10.56.217.181","routes":[{"dst":"0.0.0.0/0"}],"gateway":"10.56.217.1"}
      }'
kind: List
metadata:
  resourceVersion: ""
```

* Create application pod

```bash
$ cat 05-create-pod.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sriov-example
---
apiVersion: v1
kind: Pod
metadata:
  name: sriovpod-example
  namespace: sriov-example
  annotations:
    k8s.v1.cni.cncf.io/networks: sriovnetwork-example
spec:
  containers:
  - name: sriovpod
    command: ["/bin/sh", "-c", "trap : TERM INT; sleep 600000& wait"]
    image: ubi8/ubi

$ oc get pod -n sriov-example
NAME               READY   STATUS    RESTARTS   AGE
sriovpod-example   1/1     Running   0          11s
```

## Remove Operator 

```bash
$ oc create -f 07-delete-sriov.bash
```

## References
* https://performance-operators-lab.readthedocs.io/en/latest/#deployment-1
* https://github.com/openshift/sriov-network-operator/blob/master/doc/quickstart.md
