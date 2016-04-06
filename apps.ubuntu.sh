#!/bin/bash

g_drCur=${PWD}
g_FILE=$(basename ${0})
. $(dirname ${0})/${g_FILE%%.*}.cfg

g_drPro=$(Absolute2Dir "${g_drCur}" "$(dirname ${0})")
g_FILE=$(basename ${0})

#####################
#set
sCmdInstall="apt-get"
sCmdArgs="-y"
##########
#do
##########
#samba
appKey=update
sCmd="${sCmdInstall} ${sCmdArgs} ${appKey}"
ExpectBashExec "${sCmd}"
iRt1=$?
exit 0

${sCmdInstall} ${sCmdArgs} install samba;
useradd smb;
passwd smb;
smbpasswd -a smb

mkdir -p /opt/share
sed -n "\$a \\
[share]
comment = Root Directories
browseable = yes
writeable = yes
path = /opt/share
valid users = smb
guest ok = yes
" /etc/samba/smb.conf

#/etc/init.d/smbd restart
/usr/sbin/smbd restart
#\\192.168.1.243

##########
#vsftpd
${sCmdInstall} ${sCmdArgs} install vsftpd;
systemctl status vsftpd.service
systemctl start vsftpd.service
#service vsftpd start;
sed "
listen=YES
#listen_ipv6=YES
" vsftpd.conf

##########
#apache2
#${sCmdInstall} ${sCmdArgs} install httpd;
${sCmdInstall} ${sCmdArgs} install apache2;

##########
#php5
${sCmdInstall} ${sCmdArgs} install php5;
#${sCmdInstall} ${sCmdArgs} install php-mysql
mkdir -p /var/www/html
echo "<?php phpinfo(); ?>" >/var/www/html/testing.php
curl http://127.0.0.1/testing.php

##########
#mysql-server
${sCmdInstall} ${sCmdArgs} install mysql-server;
rcmysql start
mysql_secure_installation
mysql -u root -p
> use mysql;
> select host,user from user;

##########
#libapache2-mod-auth-mysql phpmyadmin
${sCmdInstall} ${sCmdArgs} install libapache2-mod-auth-mysql;

##########
#phpmyadmin
${sCmdInstall} ${sCmdArgs} install phpmyadmin;

##########
#DNS
#${sCmdInstall} ${sCmdArgs} install bind9;
#${sCmdInstall} ${sCmdArgs} install dnsutils;

sed -i "\$a \\GATEWAY=192.168.1.1" /etc/sysconfig/network/ifcfg-eth3

##########
#Docker
#${sCmdInstall} ${sCmdArgs} install apparmor;
${sCmdInstall} ${sCmdArgs} install docker.io

##########
#nginx
${sCmdInstall} ${sCmdArgs} install nginx;
#/etc/init.d/nginx start

##########
#mysql
#${sCmdInstall} ${sCmdArgs} install mysql
service mysql.server start

##########
#KVM
grep -iq \(.vm\|vm.\) /proc/cpuinfo;

##########
#openjdk
${sCmdInstall} ${sCmdArgs} install java-1.7.0-openjdk.aarch64
${sCmdInstall} ${sCmdArgs} install java-1.7.0-openjdk-devel.aarch64
export JAVA_HOME=/usr/lib64/jvm/java-openjdk
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH

##########
#Xen
${sCmdInstall} ${sCmdArgs} install build-essential binutils python-dev libncurses5-dev  libcurl4-openssl-dev;
${sCmdInstall} ${sCmdArgs} install xorg-dev uuid-dev bridge-utils bison flex udev gettext bin86  bcc  iasl;
${sCmdInstall} ${sCmdArgs} install libgcrypt11-dev   libssl-dev pciutils libglib2.0-dev  gcc-multilib texinfo zlib1g-dev;

##########
#LXC
${sCmdInstall} ${sCmdArgs} install lxc;
lxc-checkconfig
#lxc-create -n lxc_ubuntu -t ubuntu


#####################

