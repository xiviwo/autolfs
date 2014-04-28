#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=epdfview
version=0.1.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://anduin.linuxfromscratch.org/sources/BLFS/conglomeration/epdfview/epdfview-0.1.8.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/epdfview-0.1.8-fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" epdfview-0.1.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../epdfview-0.1.8-fixes-1.patch 
./configure --prefix=/usr 
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
