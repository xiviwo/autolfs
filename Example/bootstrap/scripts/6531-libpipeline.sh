#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libpipeline
version=1.2.6
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" libpipeline-1.2.6.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr

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
