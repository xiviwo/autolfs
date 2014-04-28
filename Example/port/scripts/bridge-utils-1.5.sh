#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bridge-utils
version=1.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/bridge-utils-1.5-linux_3.8_fix-1.patch
nwget http://sourceforge.net/projects/bridge/files/bridge/bridge-utils-1.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" bridge-utils-1.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../bridge-utils-1.5-linux_3.8_fix-1.patch 
autoconf -o configure configure.in                      
./configure --prefix=/usr                               
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-service-bridge

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.br0 << "EOF"
ONBOOT=yes
IFACE=br0
SERVICE="bridge ipv4-static"  # Space separated
IP=192.168.1.32
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
CHECK_LINK=no                 # Don't check before bridge is created
STP=no                        # Spanning tree protocol, default no
INTERFACE_COMPONENTS="eth0"   # Add to IFACE, space separated devices
IP_FORWARD=true
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
