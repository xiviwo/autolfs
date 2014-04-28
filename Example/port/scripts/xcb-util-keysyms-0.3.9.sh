#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xcb-util-keysyms
version=0.3.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://xcb.freedesktop.org/dist/xcb-util-keysyms-0.3.9.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xcb-util-keysyms-0.3.9.tar.bz2
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
