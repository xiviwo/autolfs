#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xcursor-themes
version=1.0.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/archive/individual/data/xcursor-themes-1.0.4.tar.bz2
nwget ftp://ftp.x.org/pub/individual/data/xcursor-themes-1.0.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xcursor-themes-1.0.4.tar.bz2
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
