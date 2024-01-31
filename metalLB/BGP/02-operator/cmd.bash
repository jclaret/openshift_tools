oc exec speaker-9jws9 -c frr -- vtysh -c "show bgp summary"
oc exec speaker-9jws9 -c frr -- vtysh -c "show ip bgp neighbor"
oc exec speaker-2wllr -c frr -- vtysh -c "show ip route 10.19.1.140"
oc exec speaker-2wllr -c frr -- vtysh -c "show ip bgp neighbor"
oc exec -n metallb-system speaker-66bth -c frr -- vtysh -c "show running-config"
oc exec speaker-bf948 -c frr -- rpm -q frr
oc -n metallb-system exec -it speaker-bf948 -c frr -- vtysh -c "show ip bgp 10.19.1.140"
oc -n metallb-system exec -it speaker-bf948 -c frr -- vtysh -c "show ip nht" 10.19.1.140

# LOGS
oc logs -n metallb-system speaker-7m4qw -c speaker
oc logs -n metallb-system speaker-7m4qw -c frr

# FRR
sudo podman exec -it frr-upstream vtysh -c "show bgp summary"
sudo podman exec -it frr-upstream vtysh -c "show ip bgp neighbor"
sudo podman exec -it frr-upstream vtysh -c "show bfd peers"
sudo podman exec -it frr-upstream vtysh -c "show ip route"
sudo podman exec -it frr-upstream ip r

