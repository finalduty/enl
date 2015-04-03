### finalduty@github.com [rev: 8fe91e2]
## Base setup used to prep templates or customise from scrath
#!/bin/bash

## Install and Update
yum update -y
yum update -y kernel
yum install -y vim ntp epel-release net-tools psmisc rsync

## Setup Hosts
echo -e '172.20.1.211\tprx-a01.finalduty.me prx-a01' >> /etc/hosts
echo -e '172.20.1.212\tprx-a02.finalduty.me prx-a02' >> /etc/hosts

## Configure Packages
 ## Yum
 sed -i '/^proxy/'d /etc/yum.conf
 sed -i '/\[main\]/a proxy=http://prx-a01.finalduty.me:3128' /etc/yum.conf

 ## SSH
 sed -i 's/.*PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config

## Download Configs
#mkdir ~/.ssh
#curl -L https://raw.github.com/finalduty/git/master/configs/.bashrc > ~/.bashrc
#curl -L https://raw.github.com/finalduty/git/master/configs/.vimrc > ~/.vimrc
#curl -L https://raw.github.com/finalduty/enl/master/configs/authorized_keys > ~/.ssh/authorized_keys
#for i in .bashrc .vimrc .ssh; do cp -av ~/$i /etc/skel; done

## Setup User
#user=andy
#useradd -m $user
#echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
