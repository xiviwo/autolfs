#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dhcp
version=4.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.isc.org/isc/dhcp/4.3.0/dhcp-4.3.0.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/dhcp-4.3.0-client_script-1.patch
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/dhcp-4.3.0-missing_ipv6-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" dhcp-4.3.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../dhcp-4.3.0-missing_ipv6-1.patch

patch -Np1 -i ../dhcp-4.3.0-client_script-1.patch 
CFLAGS="-D_PATH_DHCLIENT_SCRIPT='\"/sbin/dhclient-script\"' -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"' -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'" ./configure --prefix=/usr --sysconfdir=/etc/dhcp --localstatedir=/var --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases --with-cli-lease-file=/var/lib/dhclient/dhclient.leases --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases 
make

make -C client install         
mv -v /usr/sbin/dhclient /sbin 
install -v -m755 client/scripts/linux /sbin/dhclient-script

make -C server install

make install                   
mv -v /usr/sbin/dhclient /sbin 
install -v -m755 client/scripts/linux /sbin/dhclient-script

cat > /etc/dhcp/dhclient.conf << "EOF"
# Begin /etc/dhcp/dhclient.conf
#
# Basic dhclient.conf(5)

#prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        netbios-name-servers, netbios-scope, interface-mtu,
        ntp-servers;
require subnet-mask, domain-name-servers;
#timeout 60;
#retry 60;
#reboot 10;
#select-timeout 5;
#initial-interval 2;

# End /etc/dhcp/dhclient.conf
EOF

install -v -dm 755 /var/lib/dhclient

dhclient <eth0>

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-service-dhclient

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

cat > /etc/sysconfig/ifconfig.eth0 << "EOF"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhclient"
DHCP_START=""
DHCP_STOP=""

# Set PRINTIP="yes" to have the script print
# the DHCP assigned IP address
PRINTIP="no"

# Set PRINTALL="yes" to print the DHCP assigned values for
# IP, SM, DG, and 1st NS. This requires PRINTIP="yes".
PRINTALL="no"
EOF

cat > /etc/dhcp/dhcpd.conf << "EOF"
# Begin /etc/dhcp/dhcpd.conf
#
# Example dhcpd.conf(5)

# Use this to enble / disable dynamic dns updates globally.
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# This is a very basic subnet declaration.
subnet 10.254.239.0 netmask 255.255.255.224 {
  range 10.254.239.10 10.254.239.20;
  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
}

# End /etc/dhcp/dhcpd.conf
EOF

install -v -dm 755 /var/lib/dhcpd

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-dhcpd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
