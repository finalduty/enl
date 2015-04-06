### finalduty@github.com [rev: 8ff091c]
## First Run script to assign identity
#!/bin/bash

## Global Variables
exitcode=""
host=""
domain=""
cidr=""
ip=""
netmask=""
gateway=""

## Functions
err() {
 case $1 in
  0)	echo "OK" ;;
  1)	echo "Generic Exit" ;;
  2)	break ;;
  3)	echo "ERROR - Invalid Hostname" ;;
  4)	exit ;;
  5)	echo "ERROR - Failure in setHostname()"; exit ;;
  *)	echo "Unhandled Error" ;;
 esac
}	       

checkSafeToRun() {
 while [ `hostname | grep localhost -c` -eq 0 ] ; do
  read -p `grep --color=always -e '^.*$' <(echo "Hostname has already been conigured - Continue? [y/N]")` yn
  echo
  case $yn in
   [yY]*) break ;;
   [nN]*) exit ;;
  esac
 done
}

inputHostname() {
 while : ; do
  echo
  read -p " [ ] Hostname (eg. srv-a01): " host
  read -p " [ ] Domain  [finalduty.me]: " domain
  testHostname;
 done
}

testHostname() {
 [[ $host = "" ]] && echo "Invalid Hostname" && return 1
 [[ $domain = "" ]] && eval domain="finalduty.me"

 setHostname;
}

setHostname() {
 echo " [ ] FQDN: $host.$domain"
 echo
 read -p " -+- Commit? [y/N/q]: " yn
 echo
 case $yn in
  [yY]*)
	echo -e "127.0.1.1\t$host.$domain $host" 2>/dev/null >> /etc/hosts
	echo "$host.$domain" 2>/dev/null > /etc/hostname
	;;
  [qQ]*) 	echo "Cancelling Setup"; exit ;;
  *)	eval exitcode=1; echo; echo "# Starting Over" ;;
 esac
 break 
}

inputIP() {
 while : ; do
  echo
  PS3="Pick Network Type: "
  select i in DHCP Static; do
   echo
   case $i in
    DHCP) 	setDynamicIP ;;
    Static) 	inputStaticIP ;;
    *) 	echo "Invalid Selection" ;;
   esac
  done
 done
}

inputStaticIP() {
 while : ; do
  read -p " [ ] IP and CIDR (eg. 192.168.1.1/24): " cidr
  read -p " [ ] Gateway (eg. 192.168.1.254): " gateway
  testStaticIP;
 done
}

testStaticIP() {
 ip=`echo $cidr | cut -d/ -f1`
 netmask=`ipcalc $cidr -m 2>/dev/null | cut -d= -f2`
 test="*"
 [ `ipcalc -c $ip 2>/dev/null; echo $?` = 1 ] && test=$test"|IPADDR"
 [ `ipcalc -c $netmask 2>/dev/null; echo $?` = 1 ] && test=$test"|NETMASK"
 [ `ipcalc -c $gateway 2>/dev/null; echo $?` = 1 ] && test=$test"|GATEWAY"

 echo
 cat << EOF | egrep --color=always $test
  IPADDR=$ip
  NETMASK=$netmask
  GATEWAY=$gateway
  DNS1=8.8.8.8
  DNS2=8.8.4.4

EOF
 [ $test != "*" ] && echo -e "ERROR -`echo $test | sed -e 's/\*//' -e 's/|/ /g'` Invalid\n" && return 1

 read -p " -+- Commit? [y/N/q]: " yn
 case $yn in
   [yY]*) 	setStaticIP ;;
   [qQ]*) 	echo "Cancelling Setup" ; exit ;;
   *) 	echo ;;
 esac
}

setStaticIP() {
  file="/etc/sysconfig/network-scripts/ifcfg-ens192"
  cat << EOF  >> $file
IPADDR=$ip
NETMASK=$netmask
GATEWAY=$gateway
DNS1=8.8.8.8
DNS2=8.8.4.4

EOF
  hwaddr=`ip a | grep -m1 link/ether | awk '{print $2}'`
  sed -i '/BOOTPROTO/ s/=.*$/=none/' $file
  sed -i -e '/^UUID/ s/^/#/' $file
  sed -i "/HWADDR/ s/=.*$/=\"$hwaddr\"/" $file
  echo "Static IP Written"
  break 3
}

setDynamicIP() {
  file="/etc/sysconfig/network-scripts/ifcfg-ens192"
  hwaddr=`ip a | grep -m1 link/ether | awk '{print $2}'`
  sed -i '/BOOTPROTO/ s/=.*$/=dhcp/' $file
  sed -i -e '/DNS/d' -e '/NETMASK/d' -e '/GATEWAY/d' -e '/IPADDR/d' $file
  sed -i -e '/^UUID/ s/^/#/' $file
  sed -i "/HWADDR/ s/=.*$/=\"$hwaddr\"/" $file
  
  systemctl restart network
  echo "DHCP has been configured"
  break 2 
}

runBaseConfig() {
  bash <(curl -L https://raw.githubusercontent.com/finalduty/enl/master/install/base.sh)
}

runInstall() {
#  bash <(curl -L https://raw.githubusercontent.com/finalduty/enl/master/install/auto.sh)
}

setupFirewall() {
  curl -L https://raw.githubusercontent.com/finalduty/enl/master/configs/firewall > /etc/sysconfig/firewall
  sh /etc/sysconfig/firewall
}


## __Main__
checkSafeToRun;
setupFirewall;
inputHostname;
inputIP; 
runBaseConfig;
runInstall;
