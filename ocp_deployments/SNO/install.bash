# kcli create network -c 192.168.126.0/24 -P dhcp=false -P dns=false -d 2620:52:0:1306::0/64 --domain 5g-deployment.lab --nodhcp 5gdeploylabdual
kcli create cluster openshift --pf ./sno.yaml
