#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libunique
version=1.1.6
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/libunique/1.1/libunique-1.1.6.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libunique-1.1.6-upstream_fixes-1.patch
nwget http://ftp.gnome.org/pub/gnome/sources/libunique/1.1/libunique-1.1.6.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libunique-1.1.6.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libunique-1.1.6-upstream_fixes-1.patch 
autoreconf -fi 

./configure --prefix=/usr --disable-dbus --disable-static 
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
