#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=util-macros
version=1.18.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://xorg.freedesktop.org/releases/individual/util/util-macros-1.18.0.tar.bz2
nwget ftp://ftp.x.org/pub/individual/util/util-macros-1.18.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" util-macros-1.18.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
