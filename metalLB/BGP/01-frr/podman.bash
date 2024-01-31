# https://www.redhat.com/en/blog/metallb-in-bgp-mode
sudo podman run -d --rm  -v /home/kni/tmp-jordi/metalLB/BGP/01-frr:/etc/frr:Z --net=host --name frr-upstream --privileged quay.io/frrouting/frr:9.0.2
