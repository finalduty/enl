## First Run script to assign identity
#!/bin/bash

## Global Variables
host=""
domain=""
exitcode=""

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

inputHostname() { exitcode=1
 echo
 while : ; do
  read -p " [ ] Hostname (eg. srv-a01): " host
  read -p " [ ] Domain  [finalduty.me]: " domain
  testHostname; 	err $?
 done

 setHostname; 	#err $?
 
 return $exitcode
}

testHostname() { exitcode=1
 [[ $host = "" ]] && eval exitcode=3 || eval exitcode=2
 [[ $domain = "" ]] && eval domain="finalduty.me"
 
 return $exitcode
}

setHostname() { exitcode=1
 echo " [ ] FQDN: $host.$domain"
 read -p " -+- Commit? [y/N]: " yn
 case $yn in
  [yY]*)
  	eval exitcode=5;
	eval i=0
	echo
	echo -e "127.0.1.1\t$host.$domain $host" 2>/dev/null >> /etc/hosts && eval i=$(($i+1))
	echo "$host.$domain" 2>/dev/null > /etc/hostname && eval i=$(($i+2))
	echo -n "$i - " 
	;;
  *)	eval exitcode=1; echo; echo "# Starting Over" ;;
 esac
 
 return $exitcode
}

## __Main__
while : ; do inputHostname; 	err $?; done
