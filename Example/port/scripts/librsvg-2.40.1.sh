#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=librsvg
version=2.40.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.1.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" librsvg-2.40.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-vala --disable-static 
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
