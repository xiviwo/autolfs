#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mpfr
version=3.1.2
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" mpfr-3.1.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-thread-safe --docdir=/usr/share/doc/mpfr-3.1.2

make



make install

make html


make install-html

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
