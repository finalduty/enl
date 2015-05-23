## Install Script for Exim Mail Filter
#!/bin/bash

##### Notes #####
## http://commons.oreilly.com/wiki/index.php/SpamAssassin/Integrating_SpamAssassin_with_Exim
## http://www.timj.co.uk/uploads/Exim-SpamAndVirusScanning.pdf
## 

##### Script #####

## Variables
sa_conf='/etc/mail/spamassassin/local.cf'
ca_conf='/etc/clamd.d/scan.conf'

##### Functions #####
dcc_install() {
  yum -y install dcc
}
dcc_setup() {
  sed -i 's/loadplugin Mail::SpamAssassin::Plugin::DCC s/^#//' $sa_conf
}

pyzor_install() {
  pip install pyzor
}
pyzor_setup() {
  echo "pyzor_options --homedir /etc/mail/spamassassin" >> $sa_conf
}
iptables_setup() {
  systemctl stop firewalld; systemctl mask firewalld
  systemctl enable iptables
  curl https://git.webhost.co.nz/sysadmin/install/raw/master/configs/firewall > /etc/sysconfig/firewall 
  sed -i '/--dport 25 -j ACCEPT/ s/^#//' /etc/sysconfig/firewall
  sh /etc/sysconfig/firewall
  iptables-save > /etc/sysconfig/iptables
  systemctl restart iptables
}

spamassasin_install() {
  yum -y install spamassassin spamassassin-iXhash2
}
spamassassin_setup() {
  useradd -r spamd
  usermod -aG spamd nobody
  mkdir -p /var/spool/exim/.spamassassin
  chown exim. /var/spool/exim/.spamassassin
  chmod 700 /var/spool/exim/.spamassassin
  
  sed -i '/^rewrite_header/ s/^/#/' $sa_conf
  sed -i '/^report_safe/ s/[0-9]*$/0/' $sa_conf
  sed -i '/^required_hits/ s/[0-9]*$/10/' $sa_conf
  sed -i '/^SPAMDOPTIONS/'d /etc/sysconfig/spamassassin
  echo 'SPAMDOPTIONS=-d -c -m5 -H -l -uspamd -gspamd --socketpath=/var/run/spamd/spamd.sock' >> /etc/sysconfig/spamassassin
  
  systemctl enable spamassassin
  systemctl start spamassassin
  sa-update
}

clamav_install() {
  yum -y install clamav-scanner clamav-update clamav-scanner-systemd clamav-server-systemd
}
clamav_setup() {
  sed -i '/REMOVE ME/'d /etc/sysconfig/freshclam
  sed -i '/^Example/ s/^/#/' /etc/freshclam.conf
  sed -i '/^Example/ s/^/#/' $ca_conf
  sed -i '/LocalSocket/ s/^#//' $ca_conf
  sermod clamscan -aG clamupdate
  setsebool antivirus_can_scan_system 1
  setsebool -P antivirus_can_scan_system 1
  chmod 755 /var/run/clamd.scan
  
  freshclam
  systemctl enable clamd@scan
  systemctl start clamd@scan
} 

exim_install() {
  yum -y install exim
}
exim_setup() {
  usermod -aG exim nobody
  mv /etc/exim/exim.conf{,.rpmsave}
  curl https://raw.githubusercontent.com/finalduty/enl/master/mlf/exim.conf > /etc/exim/exim.conf
  sed -i '/ExecStart=/ s/$/ -N/' /usr/lib/systemd/system/exim.service  ## Disable message delivery for testing only
  systemctl daemon-reload
  systemctl enable exim
  systemctl restiart exim
}

##### Execute #####

## Update and Install
yum -y install epel-release http://www6.atomicorp.com/channels/atomic/centos/7/x86_64/RPMS/atomic-release-1.0-19.el7.art.noarch.rpm
yum -y update
yum -y install iptables-services setroubleshoot-server screen python-pip bash-completion 

## Run Functions
#clamav_install
dcc_install
exim_install
spamassassin_install
pyzor_install

pyzor_setup
dcc_setup
spamassassin_setup
exim_setup

exit 0 ## Done :D

