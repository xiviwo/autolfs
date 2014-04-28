#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xchat
version=2.8.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/xchat-2.8.8-glib-2.31-1.patch
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xchat-2.8.8.tar.bz2
nwget http://www.xchat.org/files/source/2.8/xchat-2.8.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xchat-2.8.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../xchat-2.8.8-glib-2.31-1.patch 

LIBS+="-lgmodule-2.0" ./configure --prefix=/usr --sysconfdir=/etc --enable-shm 
make

make install 
install -v -m755 -d /usr/share/doc/xchat-2.8.8 
install -v -m644    README faq.html /usr/share/doc/xchat-2.8.8


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
