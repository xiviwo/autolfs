#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=general-network-configuration
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
:
}
build()
{


cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.122.13
GATEWAY=192.168.122.1
PREFIX=24
BROADCAST=192.168.122.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain ibm.com
}
download;unpack;build
