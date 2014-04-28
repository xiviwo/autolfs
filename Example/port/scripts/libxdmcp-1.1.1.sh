#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libxdmcp
version=1.1.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.x.org/pub/individual/lib/libXdmcp-1.1.1.tar.bz2
nwget http://xorg.freedesktop.org/releases/individual/lib/libXdmcp-1.1.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libXdmcp-1.1.1.tar.bz2
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
