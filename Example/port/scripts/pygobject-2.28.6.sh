#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pygobject
version=2.28.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-2.28.6.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/pygobject/2.28/pygobject-2.28.6.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/pygobject-2.28.6-fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" pygobject-2.28.6.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../pygobject-2.28.6-fixes-1.patch   
./configure --prefix=/usr --disable-introspection 
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
