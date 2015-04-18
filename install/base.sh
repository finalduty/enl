### finalduty@github.com [rev: 90177ca]
## Base setup used to prep templates or customise from scrath
#!/bin/bash

## Variables
myip=`ip a | grep "inet 172" | sed -e 's/\/.*//' -e 's/.* //'`
mytype=`hostname | sed 's/-.*//'`

## Install and Update
yum clean all
yum update -y
yum update -y kernel
yum remove -y wget ntp
yum install -y vim epel-release net-tools psmisc rsync tcpdump

## Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disableipv6.conf

## Create Directories
for dir in /data /nfs; do mkdir -pv $dir; done
echo -e "nfs.finalduty.me:/\t/nfs\tnfs4\tdefaults\t0 0" >> /etc/fstab
mount -av

## Configure Yum
sed -i '/proxy=/'d /etc/yum.conf
sed -i '/\[main\]/a proxy=http://prx-a01.finalduty.me:3128' /etc/yum.conf
sed -i '/^mirrorlist=/ s/^/#/' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/baseurl=/ s/.*/baseurl=http:\/\/mirror.webhost.co.nz\/centos\/\$releasever\/os\/\$basearch\//' /etc/yum.repos.d/CentOS-Base.repo

## Configure SSH
sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config
sed -i '/UseDNS/ s/.*/UseDNS no/' /etc/ssh/sshd_config

## Download Other Configs
mkdir -p /etc/skel/.ssh
curl -L https://raw.githubusercontent.com/finalduty/git/master/configs/.bashrc > /etc/skel/.bashrc
curl -L https://raw.githubusercontent.com/finalduty/git/master/configs/.vimrc > /etc/skel/.vimrc
curl -L https://raw.githubusercontent.com/finalduty/git/master/configs/authorized_keys > /etc/skel/.ssh/authorized_keys
cp -R /etc/skel /root

## Setup User
for user in andy; do 
  useradd -m $user
  echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
done
