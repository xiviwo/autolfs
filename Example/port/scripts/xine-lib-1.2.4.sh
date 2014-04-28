#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xine-lib
version=1.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/xine/xine-lib-1.2.4.tar.xz
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-lib-1.2.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" xine-lib-1.2.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-vcd --docdir=/usr/share/doc/xine-lib-1.2.4 
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
