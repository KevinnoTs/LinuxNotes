#!/bin/sh
##
## Powered by KevinnoTs
## 2018/09/06
## QQ:263296
##

#### export PATH
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#### Define var
date=$(date +%F)

#### Shell start
clear

# set alias
echo -e "\033[36mStarting set alias...\033[0m" &&\
ali=$(cat /etc/bashrc | grep "alias grep=.*color.*" | wc -l)
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias cls='clear'
if [ $ali -eq 0 ];then
  if [ -f "/etc/bashrc" ];then
    cp /etc/bashrc{,.$date}
  fi
  cat >>/etc/bashrc<<EOF

# User specific aliases and functions by KevinnoTs at $date
alias grep='grep --color=auto'
EOF
fi
echo -e "\033[31mSet alias is done!\033[0m" &&\
sleep 2
clear

# set source of yum to aliyun.com
echo -e "\033[36mStarting set source of yum to aliyun.com...\033[0m" &&\
#yum install -y wget
#wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/Centos-6.repo
if [ ! -f "/etc/yum.repos.d/Centos-6.repo" ];then
  curl -O http://mirrors.aliyun.com/repo/Centos-6.repo &&\
  mv ./Centos-6.repo /etc/yum.repos.d/ &&\
  if [ -f "/etc/yum.repos.d/CentOS-Base.repo" ];then
    mv /etc/yum.repos.d/CentOS-Base.repo{,.$date}
  fi
fi
echo -e "\033[31mSet source is done!\033[0m" &&\
sleep 2
clear

# yum groupinstall
echo -e "\033[36mStarting yum module...\033[0m" &&\
yum groupinstall -y "Base" "Compatibility libraries" "Debugging tools" "Development tools" &&\
echo -e "\033[31mYum module is done!\033[0m" &&\
sleep 2
clear


# yum install
echo -e "\033[36mStarting yum packages...\033[0m" &&\
yum install -y ntpdate tree lrzsz
yum makecache
yum install -y epel-release
yum update -y
echo -e "\033[31mYum packages is done!\033[0m" &&\
sleep 2
clear

# sync time
echo -e "\033[36mStaring sync time...\033[0m" &&\
ntpdate times.aliyun.com &&\
echo -e "\033[31mTime sync done!\033[0m" &&\
sleep 2
clear

# sync time crontab
echo -e "\033[36mStaring set crontab of sync time...\033[0m" &&\
if [ -f "/var/spool/cron/root" ];then
  ntp=$(crontab -l | grep "^\*.*ntpdate.*>/dev/null" | wc -l)
  if [ $ntp -eq 0 ];then
    cp /var/spool/cron/root{,.$date}
    cat >>/var/spool/cron/root<<EOF

# Time sync by KevinnoTs at $date
*/5 * * * * /usr/sbin/ntpdate times.aliyun.com >/dev/null 2>&1
EOF
  fi
else
  touch /var/spool/cron/root
  cat >>/var/spool/cron/root<<EOF
# Time sync by KevinnoTs at $date
*/5 * * * * /usr/sbin/ntpdate times.aliyun.com >/dev/null 2>&1
EOF
fi
echo -e "\033[31mSet crontab of sync time is done!\033[0m" &&\
sleep 2
clear

# set SELinux off
echo -e "\033[36mStaring set SELinux off...\033[0m" &&\
selinuxable=$(cat /etc/selinux/config | grep "SELINUX=disabled" | wc -l)
if [ $selinuxable -eq 0 ];then
  if [ -f "/etc/selinux/config" ];then
    cp /etc/selinux/config{,.$date}
  fi
  sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
fi
setenforce 0 &&\
echo -e "\033[31mSELinux is stop!\033[0m" &&\
sleep 2
clear

# chkconfig useless service off
echo -e "\033[36mStaring off the useless services...\033[0m" &&\
chkconfig --list | grep "3:on" | egrep -v "crond|sshd|network|rsyslog|sysstat" \
  | awk '{print "chkconfig",$1,"off"}'
chkconfig --list | grep "3:on" | egrep -v "crond|sshd|network|rsyslog|sysstat" \
  | awk '{print "chkconfig",$1,"off"}' | bash &&\
echo -e "\033[31mUseless services is off!\033[0m" &&\
sleep 2
clear

# set iptables off
echo -e "\033[36mStaring set iptables off...\033[0m" &&\
sleep 1
/etc/init.d/iptables stop ||\
/etc/init.d/iptables stop
chkconfig iptables off &&\
echo -e "\033[31mIptables is off!\033[0m" &&\
sleep 2
clear

# set file descriptor
echo -e "\033[36mStaring set file descriptor...\033[0m" &&\
sleep 1
fileconf=$(cat /etc/security/limits.conf \
  | grep "*                -       nofile          65535" \
  | wc -l)
if [ $fileconf -eq 0 ];then
  if [ -f "/etc/security/limits.conf" ];then
    cp /etc/security/limits.conf{,.$date}
  fi
  sed -ir 's#^\#\*\s*hard\s*rss\s*10000#&\n\*                -       nofile          65535#' \
  /etc/security/limits.conf
fi
echo -e "\033[31mSet file descriptor is done!\033[0m" &&\
sleep 2
clear

# add newusers and newgroup
sudoks=$(cat /etc/sudoers | grep "ks      ALL=(ALL)       NOPASSWD: ALL" | wc -l)
gkshome=$(cat /etc/group | grep -w "kshome" | wc -l)
uks=$(cat /etc/passwd | grep -w "ks" | wc -l)
echo -e "\033[36mAdding new group and user...\033[0m" &&\
sleep 1
if [ $gkshome -eq 0 ];then
  groupadd kshome
fi
if [ $uks -eq 0 ];then
  useradd ks -g kshome
fi
echo "qwert123" | passwd --stdin ks
id ks
sleep 3
if [ $sudoks -eq 0 ];then
  cp /etc/sudoers{,.$date}
  sed -ir 's#root\s*ALL=(ALL)\s*ALL#&\nks      ALL=(ALL)       NOPASSWD: ALL#' \
    /etc/sudoers
fi
sudoerr=$(echo `visudo -c` | grep "parsed OK" | wc -l)
if [ $sudoerr -eq 0 ];then
  echo -e "\033[1;5;31mParse error in /etc/sudoers! Pleas check and repair it!!\033[0m" &&\
  echo -e "\033[1;31mParse error in /etc/sudoers! Pleas check and repair it!!\033[0m" &&\
  echo -e "\033[1;5;36mParse error in /etc/sudoers! Pleas check and repair it!!\033[0m" &&\
  echo -e "\033[1;36mParse error in /etc/sudoers! Pleas check and repair it!!\033[0m" &&\
  exit 0;
fi
echo -e "\033[31mNew group and user is added!\033[0m" &&\
sleep 2
clear

# kernel optimize
echo -e "\033[36mSeting kernel optimize...\033[0m" &&\
keropt=$(cat /etc/sysctl.conf | grep "Kernel.*KevinnoTs" | wc -l)
if [ $keropt -eq 0 ];then
  cp /etc/sysctl.conf{,.$date}
  cat >>/etc/sysctl.conf<<EOF

# Kernel optimize by KevinnoTs at $date
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_orphans = 16384
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.route.gc_timeout = 100
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
EOF
fi
sleep 1
sysctl -p
echo -e "\033[31mKernel optimize is done!\033[0m" &&\
sleep 2
clear

# Package the changed file
echo -e "\033[36mBackup the changed files...\033[0m" &&\
mkdir -p /server/scripts
cp ./opt_new.sh /server/scripts/opt_newhost_all.sh
BACKUP_DIR=$(echo `ifconfig eth1 | awk -F "[ :]+" 'NR==2 {print $4}'`_$HOSTNAME)
BACKUP_PATH=/backup
BACKUP_DATE=$(echo $(date +%F)_$(date | cut -c-3))
if [ ! -d "$BACKUP_PATH/$BACKUP_DIR" ];then
  mkdir -p $BACKUP_PATH/$BACKUP_DIR
fi
cd / &&\
tar zcfh $BACKUP_PATH/$BACKUP_DIR/backup_sys_conf_${BACKUP_DATE}.tar.gz \
  ./var/spool/cron/ ./etc/rc.local ./server/scripts/ ./etc/hosts
# All setting are done
echo -e "\033[31mAll settings are DONE!! Enjoying it!\033[0m" &&\
sleep 3
echo "The system is going down for reboot in 1 minute!"
echo "Please wait or press CTRL+C to cancel..."
shutdown -r +1
#
#### Shell end