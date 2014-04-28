#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=binutils
version=2.24
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" binutils-2.24.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
expect -c ""

rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in

mkdir -pv ../binutils-build
cd ../binutils-build

../binutils-2.24/configure --prefix=/usr --enable-shared

make tooldir=/usr



make tooldir=/usr install

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
