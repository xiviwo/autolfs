#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=glamor-egl
version=0.6.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/archive/individual/driver/glamor-egl-0.6.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" glamor-egl-0.6.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG --enable-glx-tls 
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
