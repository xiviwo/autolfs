#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=general
version=
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.1
GATEWAY=192.168.1.2
PREFIX=24
BROADCAST=192.168.1.255
EOF
cat > /etc/resolv.conf << "EOF"
	# Begin /etc/resolv.conf
domain <Your Domain Name>
nameserver 	<IP address of your primary nameserver>
nameserver 	<IP address of your secondary nameserver>
# End /etc/resolv.conf
EOF
