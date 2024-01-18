#!/bin/bash
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
	echo "All fine, MCP status: ${status}"
}

wait_mcp
