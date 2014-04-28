#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xinit
version=1.3.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/releases/individual/app/xinit-1.3.3.tar.bz2
nwget ftp://ftp.x.org/pub/individual/app/xinit-1.3.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xinit-1.3.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG --with-xinitdir=/etc/X11/app-defaults 
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
