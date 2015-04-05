## Install script for DHCP
#!/bin/bash

yum update -y; yum install dhcpd

curl -L https://raw.githubusercontent.com/finalduty/enl/master/svc/dhcpd.conf > /etc/dhcpd.conf

systemctl enable dhcpd
systemctl start dhcpd
