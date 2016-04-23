#!/bin/bash

g_drCur=${PWD}
g_FILE=$(basename ${0})
. $(dirname ${0})/${g_FILE%%.*}.cfg

g_drPro=$(Absolute2Dir "${g_drCur}" "$(dirname ${0})")
g_FILE=$(basename ${0})

#####################
#do
##########
SupportCmdTest
exit 1

#samba
zypper -n update;
zypper -n install samba;
useradd smb;
passwd smb;
smbpasswd -a smb

mkdir -p /opt/share
sed "a \
[share]
comment = Root Directories
browseable = yes
writeable = yes
path = /opt/share
valid users = smb
guest ok = yes
"
"/etc/samba/smb.conf"

#/etc/init.d/smbd restart
/usr/sbin/smbd restart
#\\192.168.1.243

##########
#vsftpd
zypper -n install vsftpd;
service vsftpd start;

##########
#apache2
#https://en.opensuse.org/SDB:LAMP_setup
#zypper -n install httpd;
#zypper remove apache2;
zypper -n install apache2;
systemctl start apache2

##########
#php5
zypper -n in php5 php5-mysql apache2-mod_php5
#enable mod-php
a2enmod php5
systemctl restart apache2

sed "
<?php 
phpinfo();
?>
" /srv/www/htdocs/index.php
http://192.168.1.223/index.php

mkdir -p /var/www/html
echo "<?php phpinfo(); ?>" >/var/www/html/testing.php
curl http://127.0.0.1/testing.php

##########
#mysql-server
zypper -n install mysql-server;
service mysql.server start
mysql_secure_installation
mysql -u root -p
> use mysql;
> select host,user from user;

##########
#libapache2-mod-auth-mysql phpmyadmin
zypper -n install libapache2-mod-auth-mysql;

##########
#phpmyadmin
zypper -n install phpmyadmin;

##########
#DNS
#zypper -n install bind9;
#zypper -n install dnsutils;

sed -i "\$a \\GATEWAY=192.168.1.1" /etc/sysconfig/network/ifcfg-eth3

##########
#Docker
#zypper in docker
#systemctl start docker

#zypper -n install apparmor;
docker pull ubuntu

##########
#nginx
zypper -n install nginx;
#/etc/init.d/nginx start
systemctl start nginx.service
systemctl status nginx.service

##########
#mysql
#zypper -n install mysql
service mysql.server start

##########
#KVM
grep -iq \(.vm\|vm.\) /proc/cpuinfo;

##########
#openjdk
zypper -n install java-1_8_0-openjdk-devel
zypper -n install java-1_8_0-openjdk
export JAVA_HOME=/usr/lib64/jvm/java-openjdk
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH

##########
#Xen
zypper -n install build-essential binutils python-dev libncurses5-dev  libcurl4-openssl-dev;
zypper -n install xorg-dev uuid-dev bridge-utils bison flex udev gettext bin86  bcc  iasl;
zypper -n install libgcrypt11-dev   libssl-dev pciutils libglib2.0-dev  gcc-multilib texinfo zlib1g-dev;

##########
#LXC
zypper -n install lxc;
lxc-checkconfig
#lxc-create -n lxc_ubuntu -t ubuntu

#####################

