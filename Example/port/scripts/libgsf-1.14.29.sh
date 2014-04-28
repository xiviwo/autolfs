#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libgsf
version=1.14.29
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/libgsf/1.14/libgsf-1.14.29.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/libgsf/1.14/libgsf-1.14.29.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libgsf-1.14.29.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
