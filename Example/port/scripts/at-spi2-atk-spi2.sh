#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=at-spi2-atk
version=spi2
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.10/at-spi2-atk-2.10.2.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/2.10/at-spi2-atk-2.10.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" at-spi2-atk-2.10.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install

glib-compile-schemas /usr/share/glib-2.0/schemas


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
