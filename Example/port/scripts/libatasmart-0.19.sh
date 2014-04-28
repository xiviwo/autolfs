#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libatasmart
version=0.19
export MAKEFLAGS='-j 4'
download()
{
nwget http://0pointer.de/public/libatasmart-0.19.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libatasmart-0.19.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make docdir=/usr/share/doc/libatasmart-0.19 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
