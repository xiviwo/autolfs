#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=unbound
version=1.4.21
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.unbound.net/downloads/unbound-1.4.21.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" unbound-1.4.21.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
groupadd -g 88 unbound 
useradd -c "Unbound DNS resolver" -d /var/lib/unbound -u 88 -g unbound -s /bin/false unbound

./configure --prefix=/usr --sysconfdir=/etc --disable-static --with-pidfile=/run/unbound.pid 
make

make install 
mv -v /usr/sbin/unbound-host /usr/bin/

echo "nameserver 127.0.0.1" > /etc/resolv.conf

sed -i '/request /i\supersede domain-name-servers 127.0.0.1;' /etc/dhcp/dhclient.conf

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-unbound


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
