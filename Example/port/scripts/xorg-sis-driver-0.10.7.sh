#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-sis-driver
version=0.10.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/archive/individual/driver/xf86-video-sis-0.10.7.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/xf86-video-sis-0.10.7-upstream_fixes-1.patch
nwget ftp://ftp.x.org/pub/individual/driver/xf86-video-sis-0.10.7.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-video-sis-0.10.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../xf86-video-sis-0.10.7-upstream_fixes-1.patch 
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
