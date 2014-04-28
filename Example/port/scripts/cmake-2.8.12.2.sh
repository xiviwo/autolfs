#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cmake
version=2.8.12.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/cmake-2.8.12.2-freetype-1.patch
nwget http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" cmake-2.8.12.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../cmake-2.8.12.2-freetype-1.patch 
./bootstrap --prefix=/usr --system-libs --mandir=/share/man --docdir=/share/doc/cmake-2.8.12.2   
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
