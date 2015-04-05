### finalduty@github.com [rev: 8ff580a]
## Base setup used to prep templates or customise from scrath
#!/bin/bash

## Variables
myip=`ip a | grep "inet 172" | sed -e 's/\/.*//' -e 's/.* //'`

## Install and Update
yum clean all
yum update -y
yum update -y kernel
yum install -y vim ntp epel-release net-tools psmisc rsync tcpdump
yum remove -y wget

## Disable IPv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disableipv6.conf

## Create Directories
mkdir -p /data
mkdir -p /nfs
echo -e "172.20.2.231:/\t/nfs\tnfs4\tdefaults\t0 0" >> /etc/fstab
mount -av

## Configure Packages
 ## Yum
 sed -i '/^proxy/'d /etc/yum.conf
 sed -i '/\[main\]/a proxy=http://prx-a01.finalduty.me:3128' /etc/yum.conf
 sed -i '/^mirrorlist/ s/^/#/' /etc/yum.repos.d/CentOS-Base.repo
 sed -i '/baseurl=/ s/.*/baseurl=http:\/\/mirror.webhost.co.nz\/centos\/\$releasever\/os\/\$basearch\//' /etc/yum.repos.d/CentOS-Base.repo

 ## SSH
 sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config

 ## Network
 sed -i '/^UUID/ s/^/#/' /etc/sysconfig/network-scripts/ifcfg-ens*

## Download Configs
mkdir -p ~/.ssh
curl -L https://raw.githubusercontent.com/finalduty/git/master/configs/.bashrc > ~/.bashrc
curl -L https://raw.githubusercontent.com/finalduty/git/master/configs/.vimrc > ~/.vimrc
curl -L https://raw.githubusercontent.com/finalduty/enl/master/configs/authorized_keys > ~/.ssh/authorized_keys
for i in .bashrc .vimrc .ssh; do cp -av ~/$i /etc/skel; done

## Setup User
user=andy
useradd -m $user
echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
