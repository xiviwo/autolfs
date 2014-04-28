#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libffi
version=3.0.13
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libffi-3.0.13-includedir-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" libffi-3.0.13.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libffi-3.0.13-includedir-1.patch 
./configure --prefix=/usr --disable-static 
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
