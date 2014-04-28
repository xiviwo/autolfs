#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-vesa-driver
version=2.3.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.x.org/pub/individual/driver/xf86-video-vesa-2.3.3.tar.bz2
nwget http://xorg.freedesktop.org/archive/individual/driver/xf86-video-vesa-2.3.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-video-vesa-2.3.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG 
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
