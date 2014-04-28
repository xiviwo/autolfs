#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cyrus-sasl
version=2.1.26
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.cyrusimap.org/cyrus-sasl/cyrus-sasl-2.1.26.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cyrus-sasl-2.1.26-fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" cyrus-sasl-2.1.26.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../cyrus-sasl-2.1.26-fixes-1.patch 
autoreconf -fi 
pushd saslauthd
autoreconf -fi 
popd
./configure --prefix=/usr --sysconfdir=/etc --enable-auth-sasldb --with-dbpath=/var/lib/sasl/sasldb2 --with-saslauthd=/var/run/saslauthd 
make -j1

make install 
install -v -dm755 /usr/share/doc/cyrus-sasl-2.1.26 
install -v -m644  doc/{*.{html,txt,fig},ONEWS,TODO} saslauthd/LDAP_SASLAUTHD /usr/share/doc/cyrus-sasl-2.1.26 
install -v -dm700 /var/lib/sasl

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-saslauthd


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
