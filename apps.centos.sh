#!/bin/bash

g_drCur=${PWD}
g_FILE=$(basename ${0})
. $(dirname ${0})/${g_FILE%%.*}.cfg

g_drPro=$(Absolute2Dir "${g_drCur}" "$(dirname ${0})")
g_FILE=$(basename ${0})

#####################
#do
#http://www.jb51.net/os/RedHat/1052.html
##########
SupportCmdTest
exit 1

#samba
rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
yum -y update;
yum -y install samba;
yum -y install smbfs;
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
yum -y install vsftpd;
systemctl status vsftpd.service
systemctl start vsftpd.service
#service vsftpd start;
sed "
listen=YES
#listen_ipv6=YES
" vsftpd.conf

##########
#apache2
#yum -y install httpd;
yum -y install apache2;

##########
#php5
yum -y install php5;
#yum -y install php-mysql
mkdir -p /var/www/html
echo "<?php phpinfo(); ?>" >/var/www/html/testing.php
curl http://127.0.0.1/testing.php

##########
#mysql-server
yum -y install mysql
rcmysql start
mysql_secure_installation
mysql -u root -p
> use mysql;
> select host,user from user;

##########
#libapache2-mod-auth-mysql phpmyadmin
yum -y install libapache2-mod-auth-mysql;

##########
#phpmyadmin
yum -y install phpmyadmin;

##########
#DNS
#yum -y install bind9;
#yum -y install dnsutils;

sed -i "\$a \\GATEWAY=192.168.1.1" /etc/sysconfig/network/ifcfg-eth3

##########
#Docker
#yum -y install apparmor;
yum -y install docker.io

##########
#nginx
yum -y install nginx;
#/etc/init.d/nginx start

##########
#mysql
#yum -y install mysql
service mysql.server start

##########
#KVM
grep -iq \(.vm\|vm.\) /proc/cpuinfo;

##########
#openjdk
yum -y install java-1.7.0-openjdk.aarch64
yum -y install java-1.7.0-openjdk-devel.aarch64
export JAVA_HOME=/usr/lib64/jvm/java-openjdk
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH

##########
#Xen
yum -y install build-essential binutils python-dev libncurses5-dev  libcurl4-openssl-dev;
yum -y install xorg-dev uuid-dev bridge-utils bison flex udev gettext bin86  bcc  iasl;
yum -y install libgcrypt11-dev   libssl-dev pciutils libglib2.0-dev  gcc-multilib texinfo zlib1g-dev;

##########
#LXC
yum -y install lxc;
lxc-checkconfig
#lxc-create -n lxc_ubuntu -t ubuntu

#####################

