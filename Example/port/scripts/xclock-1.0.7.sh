#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xclock
version=1.0.7
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.x.org/pub/individual/app/xclock-1.0.7.tar.bz2
nwget http://xorg.freedesktop.org/releases/individual/app/xclock-1.0.7.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xclock-1.0.7.tar.bz2
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
