#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=iptables
version=1.4.21
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.netfilter.org/pub/iptables/iptables-1.4.21.tar.bz2
nwget http://www.netfilter.org/projects/iptables/files/iptables-1.4.21.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" iptables-1.4.21.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sbindir=/sbin --with-xtlibdir=/lib/xtables --enable-libipq && 
make

make install 
ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml 
for file in ip4tc ip6tc ipq iptc xtables
do
  mv -v /usr/lib/lib${file}.so.* /lib 
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-iptables


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
