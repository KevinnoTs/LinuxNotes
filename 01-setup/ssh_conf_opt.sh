#!/bin/sh
##
## optimize the sshd config 
## Powered by KevinnoTs
## 2018-09-07
##
### export PATH
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#### Define var
date=$(date +%F)
confname="/etc/ssh/sshd_config"
optime=$(cat /etc/ssh/sshd_config | grep "^Port " | wc -l)

#### Shell start
clear

# backup ssh conf
if [ ! -f "${confname}.$date" ];then
  cp ${confname}{,.$date}
fi

## sed option
# Port
if [ $optime -eq 0 ];then
  sed -ir 's#^\#Port 22#&\nPort 52113#' $confname
else
  sed -ir 's#^Port .*#Port 52113#g' $confname
fi
cat $confname | grep "^Port " --color=auto
sleep 1

# PermitEmptyPasswords
optime=$(cat /etc/ssh/sshd_config | grep "^PermitEmptyPasswords " | wc -l)
if [ $optime -eq 0 ];then
  sed -ir 's#^\#PermitEmptyPasswords no#&\nPermitEmptyPasswords no#' $confname
else
  sed -ir 's#^PermitEmptyPasswords .*#PermitEmptyPasswords no#g' $confname
fi
cat $confname | grep "^PermitEmptyPasswords " --color=auto
sleep 1

# PermitRootLogin
optime=$(cat /etc/ssh/sshd_config | grep "^PermitRootLogin " | wc -l)
if [ $optime -eq 0 ];then
  sed -ir 's#^\#PermitRootLogin yes#&\nPermitRootLogin no#' $confname
else
  sed -ir 's#^PermitRootLogin .*#PermitRootLogin no#g' $confname
fi
cat $confname | grep "^PermitRootLogin " --color=auto
sleep 1

# GSSAPIAuthentication
optime=$(cat /etc/ssh/sshd_config | grep "^GSSAPIAuthentication no" | wc -l)
if [ $optime -eq 0 ];then
  sed -ir 's#^\#GSSAPIAuthentication no#GSSAPIAuthentication no#;s#^GSSAPIAuthentication yes#\#&#' $confname
fi
cat $confname | grep "^GSSAPIAuthentication " --color=auto
sleep 1

# UseDNS
optime=$(cat /etc/ssh/sshd_config | grep "^UseDNS " | wc -l)
if [ $optime -eq 0 ];then
  sed -ir 's#^\#UseDNS yes#&\nUseDNS no#' $confname
else
  sed -ir 's#^UseDNS .*#UseDNS no#g' $confname
fi
cat $confname | grep "^UseDNS " --color=auto

### Shell end
