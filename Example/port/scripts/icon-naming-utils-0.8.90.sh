#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=icon-naming-utils
version=0.8.90
export MAKEFLAGS='-j 4'
download()
{
nwget http://tango.freedesktop.org/releases/icon-naming-utils-0.8.90.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" icon-naming-utils-0.8.90.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
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
