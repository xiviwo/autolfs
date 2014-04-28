#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ijs
version=0.35
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.openprinting.org/download/ijs/download/ijs-0.35.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" ijs-0.35.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man --enable-shared --disable-static 
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
