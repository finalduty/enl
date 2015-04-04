### finalduty@github.com [rev: 8ff2e7f]
## Install and Configure Script for Squid Forward Proxy
#!/bin/bash

## Update and Install Squid
yum update -y; yum install -y squid

## << Configure Second Interface >>

## Configure
curl -L https://raw.githubusercontent.com/finalduty/enl/master/prx/squid.conf > /etc/squid/squid.conf
mkdir /data/squid -p

## Enable on boot and start
systemctl enable squid
systemctl start squid
