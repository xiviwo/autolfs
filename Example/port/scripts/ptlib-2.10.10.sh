#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ptlib
version=2.10.10
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/ptlib-2.10.10-bison_fixes-1.patch
nwget http://ftp.gnome.org/pub/gnome/sources/ptlib/2.10/ptlib-2.10.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" ptlib-2.10.10.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../ptlib-2.10.10-bison_fixes-1.patch 

./configure --prefix=/usr 
make

make install 
chmod -v 755 /usr/lib/libpt.so.2.10.10


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
