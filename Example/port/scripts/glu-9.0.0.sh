#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=glu
version=9.0.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.freedesktop.org/pub/mesa/glu/glu-9.0.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" glu-9.0.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=$XORG_PREFIX --disable-static 
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
