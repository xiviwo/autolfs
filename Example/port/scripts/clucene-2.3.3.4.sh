#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=clucene
version=2.3.3.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/clucene-2.3.3.4-contribs_lib-1.patch
nwget http://downloads.sourceforge.net/clucene/clucene-core-2.3.3.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" clucene-core-2.3.3.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../clucene-2.3.3.4-contribs_lib-1.patch 
mkdir -pv build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_CONTRIBS_LIB=ON .. 
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
