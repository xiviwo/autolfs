#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-vmmouse-driver
version=13.0.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/archive/individual/driver/xf86-input-vmmouse-13.0.0.tar.bz2
nwget ftp://ftp.x.org/pub/individual/driver/xf86-input-vmmouse-13.0.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-input-vmmouse-13.0.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG --with-udev-rules-dir=/lib/udev/rules.d --without-hal-callouts-dir --without-hal-fdi-dir 
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
