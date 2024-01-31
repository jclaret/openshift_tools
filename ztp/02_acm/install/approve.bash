oc patch installplan install-l5dnr --namespace multicluster-engine --type merge --patch '{"spec":{"approved":true}}'
oc patch installplan install-hzkpk --namespace openshift-operators --type merge --patch '{"spec":{"approved":true}}'
