#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sgml-common
version=0.6.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/sgml-common-0.6.3-manpage-1.patch
nwget ftp://sources.redhat.com/pub/docbook-tools/new-trials/SOURCES/sgml-common-0.6.3.tgz

}
unpack()
{
preparepack "$pkgname" "$version" sgml-common-0.6.3.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../sgml-common-0.6.3-manpage-1.patch 
autoreconf -f -i

./configure --prefix=/usr --sysconfdir=/etc 
make

make docdir=/usr/share/doc install 

install-catalog --add /etc/sgml/sgml-ent.cat /usr/share/sgml/sgml-iso-entities-8879.1986/catalog 

install-catalog --add /etc/sgml/sgml-docbook.cat /etc/sgml/sgml-ent.cat

install-catalog --remove /etc/sgml/sgml-ent.cat /usr/share/sgml/sgml-iso-entities-8879.1986/catalog 

install-catalog --remove /etc/sgml/sgml-docbook.cat /etc/sgml/sgml-ent.cat


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
