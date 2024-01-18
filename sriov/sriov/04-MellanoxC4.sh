#!/bin/bash

function main(){
#for node in $(oc get nodes -o wide --no-headers --selector=node-role.kubernetes.io/worker -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address} ); do
IFS=$'\n'
for nodes in $(oc get pods -n openshift-sriov-network-operator --selector=app=sriov-network-config-daemon -o=custom-columns=NAME:.metadata.name,NODE:.spec.nodeName --no-headers); do
	node=$(echo $nodes|awk '{print $2}')
	pod=$(echo $nodes|awk '{print $1}')
	
	devs=$(ssh -o StrictHostKeyChecking=no core@${node} "lspci | grep Mellan" | awk '{print $1}')

	for dev in $devs; do
		echo "Configuring driver for NIC ${dev} on ${pod}(${node})"
		oc exec ${pod} -n openshift-sriov-network-operator -- bash -c "mstconfig -d ${dev} -y set SRIOV_EN=1 NUM_OF_VFS=8"
	done

	echo "Rebooting ${node}"
	ssh -o StrictHostKeyChecking=no core@${node} "sudo reboot"
	wait_mcp
	echo "Configuring SRIOV VFs for NICs on ${node}"
	#ssh -o StrictHostKeyChecking=no core@${node} " for f in $(sudo su -c \"find /sys -name sriov_numvfs); do echo 8 > $f; done\" "
	ssh -o StrictHostKeyChecking=no core@${node} "find /sys/ -name sriov_numvfs -exec cat {} \;"
	ssh -o StrictHostKeyChecking=no core@${node} "find /sys/ -name sriov_numvfs -exec sudo sh -c \"echo 8 > {}\" \;"
	ssh -o StrictHostKeyChecking=no core@${node} "find /sys/ -name sriov_numvfs -exec cat {} \;"

done
}

wait_mcp()
{
	echo "Waiting until MachineConfigPool finishes his work"
	sleep 60
	#status=$(oc get mcp -o jsonpath={.items[*].status.conditions[?\(@.type==\"Updated\"\)].status})
	local status=$(oc get mcp worker -o jsonpath={.status.conditions[?\(@.type==\"Updated\"\)].status})
	#echo "status:${status}"
	local spinstr='\|/-'
	local temp
	while [ "${status}" != "True" ]; do
		temp="${spinstr#?}"
		printf " [%c]  " "${spinstr}"
		spinstr=${temp}${spinstr%"${temp}"}
		sleep 10
		status=$(oc get mcp worker -o jsonpath={.status.conditions[?\(@.type==\"Updated\"\)].status})
		printf "\b\b\b\b\b\b"
	done
	echo "MCP status ${status}"
}

main
