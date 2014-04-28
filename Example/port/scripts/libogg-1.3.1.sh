#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libogg
version=1.3.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.xz
nwget ftp://downloads.xiph.org/pub/xiph/releases/ogg/libogg-1.3.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libogg-1.3.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --docdir=/usr/share/doc/libogg-1.3.1 --disable-static 
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
