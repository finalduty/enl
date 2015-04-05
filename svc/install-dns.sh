## Script for Install of DNS Service
#!/bin/bash

yum update -y; yum install -y bind bind-utils

groupadd ddns
gpasswd -a named ddns
gpasswd -a dhcpd ddns

dnsseckey=`dnssec-keygen -a HMAC-MD5 -b 128 -r /dev/urandom -n USER DDNS`
awk '{print $7}' "$dnsseckey".key > /etc/ddns.key

chown root.ddns /etc/ddns.key
chmod 640 /etc/ddns.key

mkdir /var/named/zones

curl -L https://raw.githubusercontent.com/finalduty/enl/master/svc/named.conf > /etc/named.conf
curl -L https://raw.githubusercontent.com/finalduty/enl/master/svc/172.20.2 > /var/named/zones/172.20.2
curl -L https://raw.githubusercontent.com/finalduty/enl/master/svc/finalduty.me > /var/named/zones/finalduty.me

systemctl enable named
systemctl start named
