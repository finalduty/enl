### finalduty@github.com [rev: 8ff2e8b]
## Install KVM Virtualisation Host (RHCSA)
#!/bin/bash

yum update -y; yum group install -y "Virtualization Host"

systemctl enable libvirtd
systemctl enable chronyd

systemctl start libvirtd
systemctl start chronyd
