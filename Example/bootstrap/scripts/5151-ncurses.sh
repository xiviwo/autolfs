#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ncurses
version=5.9
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" ncurses-5.9.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/tools --with-shared --without-debug --without-ada --enable-widec --enable-overwrite

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
