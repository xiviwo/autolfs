#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=at-spi2-core
version=spi2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.10/at-spi2-core-2.10.2.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/2.10/at-spi2-core-2.10.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" at-spi2-core-2.10.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
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
