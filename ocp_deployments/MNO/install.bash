# kcli create pool -p /var/lib/libvirt/images default
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=24000 -P numcpus=8 -P disks=[100,25]  -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:01:01"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0101 -P name=hub-master0
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=24000 -P numcpus=8 -P disks=[100,25]  -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:01:02"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0102 -P name=hub-master1
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=24000 -P numcpus=8 -P disks=[100,25]  -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:01:03"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0103 -P name=hub-master2
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=12000 -P numcpus=8 -P disks=[100,500] -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:02:01"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0201 -P name=hub-odf0
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=12000 -P numcpus=8 -P disks=[100,500] -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:03:01"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0301 -P name=hub-odf1
#kcli create vm -P start=False -P uefi_legacy=true -P plan=hub -P memory=12000 -P numcpus=8 -P disks=[100,500] -P nets=['{"name": "5gdeploymentlab", "mac": "aa:aa:aa:aa:04:01"}'] -P uuid=aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0401 -P name=hub-odf2
kcli create cluster openshift --pf ./mno.yml
