#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=twm
version=1.0.8
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.x.org/pub/individual/app/twm-1.0.8.tar.bz2
nwget http://xorg.freedesktop.org/releases/individual/app/twm-1.0.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" twm-1.0.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e '/^rcdir =/s,^\(rcdir = \).*,\1/etc/X11/app-defaults,' src/Makefile.in 
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
