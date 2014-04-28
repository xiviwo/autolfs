#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xorg-wacom-driver
version=0.23.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/linuxwacom/xf86-input-wacom-0.23.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xf86-input-wacom-0.23.0.tar.bz2
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
