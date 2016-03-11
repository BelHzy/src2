#!/bin/bash

g_drCur=${PWD}
g_FILE=$(basename ${0})
. $(dirname ${0})/${g_FILE%%.*}.cfg

g_drPro=$(Absolute2Dir "${g_drCur}" "$(dirname ${0})")
g_FILE=$(basename ${0})

#####################
#do
#mysql
expect -c "
    set timeout -1
    set iRt1 5
    set n1 0
    set sPwd ${g_pwdMS}
    set nUseCmd 1
    while {\${n1}<${g_nMaxTimes}} {
        switch -ex \"\${nUseCmd}\" {
            1 {
                spawn apt-get -y update
            }
            2 {
                spawn apt-get -y upgrade
            }
            3 {
                set nUsrPwd 2
                spawn apt-get -y install mysql-server
            }
            default {
                set iRt1 0
                break
            }
        }
        expect {
            -re \"\[Pp]assword\(\[ \t]\+\[^ \t]\+.*\|\):\" {
                if {\${nUsrPwd}} {
                    send \"\${sPwd}\r\"
                    incr nUsrPwd -1
                    exp_continue
                } else {
                    set iRt1 3
                    send_tty \"\n\"
                }
            }
            -re \"Sorry, try again\\.\" {
                set nUsrPwd 0
                set iRt1 3
                send_tty \"\n\"
            }
            -re \"Unable to fetch some archive\" {
            }
            -re \"Some index files failed to download.\" {
            }
            eof {
                set iRt1 0
                #send_tty \"\n\"
            }
        }
        switch -ex \"\${iRt1}\" {
            0 {
                send_user \"\n\nsleep 60s\"
                sleep 60
                incr nUseCmd +1
            }
            {[0-9]} {
                break
            }
            default {
            }
        }
        incr n1 +1
    }
    send_user \"while {\${n1}<${g_nMaxTimes}} times exit \${iRt1}\n\"
    exit \${iRt1}
"
if [ $? -ne 0 ]; then
    exit 1
fi

#nginx
#apt-get -y --purge remove nginx
n1=1
nMax1=4
iRt1=1
while true; do
    case ${n1} in
        1)
            sInfo1="install nginx"
            apt-get -y install nginx
            ;;
        2)
            sInfo1="nginx start"
            /etc/init.d/nginx start
            ;;
        3)
            sInfo1="nginx web"
            curl http://127.0.0.1 |grep -iq "Welcome to nginx"
            ;;
        *)
            printf "%s[%3s]%5s: correct finished step[${n1}]\n" "${FUNCNAME[0]}" ${LINENO} "Info"
            break
            ;;
    esac
    if [ $? -ne 0 ]; then
        printf "%s[%3s]%5s: ${sInfo1} step[${n1}]\n" "${FUNCNAME[0]}" ${LINENO} "Error" 1>&2
        exit 1
    fi
    let n1+=1
done

#openjdk
apt-get -y install openjdk-7-jdk
if [ $? -ne 0 ]; then
    printf "%s[%3s]%5s: install openjdk-7-jdk\n" "${FUNCNAME[0]}" ${LINENO} "Error" 1>&2
    exit 1
else
    printf "%s[%3s]%5s: install openjdk-7-jdk\n" "${FUNCNAME[0]}" ${LINENO} "Info"
fi

#KVM
#egrep -q '(vmx|svm)' /proc/cpuinfo
grep -iq '\(.vm\|vm.\)' /proc/cpuinfo
if [ $? -eq 0 ]; then
    #apt-get -y install qemu-kvm qemu virt-manager virt-viewer libvirt-bin bridge-utils
    apt-get -y install qemu-kvm qemu-system libvirt-bin bridge-utils virt-manager python-spice-client-gtk
    if [ $? -eq 0 ]; then
        cp /etc/network/interfaces /etc/network/interfaces-bak
        if false; then
        #/etc/network/interfaces
        #Enabing Bridge networking br0 interface
        auto br0
        iface br0 inet static
        address 192.168.1.70
        network 192.168.1.0
        netmask 255.255.255.0
        broadcast 192.168.1.255
        gateway 192.168.1.1
        dns-nameservers 223.5.5.5
        bridge_ports eth0
        bridge_stp off
        #重启
        #ifconfig br0
        #virt-manager
        #创建新虚拟机: 文件/new virtual machine
        fi
    fi
else
    printf "%s[%3s]%5s: not support virtual os\n" "${FUNCNAME[0]}" ${LINENO} "Warn"
    exit 1
fi

#####################
if false; then
    #apt-get -y --force-yes install samba
    apt-get -y install samba
    adduser smb
    smbpasswd -a smb
    mkdir /home/smb/share
    vim /etc/samba/smb.conf
        [share]
        comment = Root Directories
        browseable = yes
        writeable = yes
        path = /home/smb/share
        valid users = smb
        guest ok = yes
    /etc/init.d/smbd restart

    apt-get -y install vsftpd
fi

