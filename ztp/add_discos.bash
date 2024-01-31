for node in {0..2}
do
sudo virsh detach-disk rna1-vmaster-${node} sdb
sudo rm -i /var/lib/libvirt/images/rna1-vmaster-${node}-extra-disk-01.qcow2
sudo qemu-img create /var/lib/libvirt/images/rna1-vmaster-${node}-extra-disk-01.qcow2 100G
sudo virsh attach-disk rna1-vmaster-${node} /var/lib/libvirt/images/rna1-vmaster-${node}-extra-disk-01.qcow2 sdb --cache none
done
# qemu-img create -f qcow2 /var/lib/libvirt/images/rna1-vmaster-0-extra-disk-01.qcow2 100G
# virsh attach-disk rna1-vmaster-0 /var/lib/libvirt/images/rna1-vmaster-0-extra-disk-01.qcow2 --target sdb --persistent --live
#virsh detach-disk rna1-vmaster-0 sdb --persistent --live
#sudo dd if=/dev/zero of=/var/lib/libvirt/images/rna1-vmaster-${node}-extra-disk-01.qcow2 bs=1M count=5120 status=progress
