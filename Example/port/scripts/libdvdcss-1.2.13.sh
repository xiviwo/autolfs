#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdvdcss
version=1.2.13
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.videolan.org/pub/libdvdcss/1.2.13/libdvdcss-1.2.13.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libdvdcss-1.2.13.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/libdvdcss-1.2.13 
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
