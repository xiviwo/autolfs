#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cogl
version=1.16.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/cogl/1.16/cogl-1.16.2.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/cogl/1.16/cogl-1.16.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" cogl-1.16.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-gles1 --enable-gles2 
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
