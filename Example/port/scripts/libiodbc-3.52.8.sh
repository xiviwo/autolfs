#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libiodbc
version=3.52.8
export MAKEFLAGS='-j 1'
download()
{
nwget http://downloads.sourceforge.net/project/iodbc/iodbc/3.52.8/libiodbc-3.52.8.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libiodbc-3.52.8-parallel_build-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" libiodbc-3.52.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libiodbc-3.52.8-parallel_build-1.patch 
autoreconf -fiv 

./configure --prefix=/usr --with-iodbc-inidir=/etc/iodbc --includedir=/usr/include/iodbc --disable-libodbc --disable-static                
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
