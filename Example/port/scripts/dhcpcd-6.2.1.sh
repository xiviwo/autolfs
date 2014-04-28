#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dhcpcd
version=6.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://roy.marples.name/downloads/dhcpcd/dhcpcd-6.2.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" dhcpcd-6.2.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --libexecdir=/lib/dhcpcd --dbdir=/var/tmp         
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-service-dhcpcd

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhcpcd"
DHCP_START="-b -q <insert appropriate start options here>"
DHCP_STOP="-k <insert additional stop options here>"
EOF

cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhcpcd"
DHCP_START="-b -q -S ip_address=192.168.0.10/24 -S routers=192.168.0.1"
DHCP_STOP="-k"
EOF

cat > /etc/resolv.conf.head << "EOF"
# OpenDNS servers
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
