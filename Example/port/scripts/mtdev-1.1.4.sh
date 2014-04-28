#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mtdev
version=1.1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://bitmath.org/code/mtdev/mtdev-1.1.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" mtdev-1.1.4.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
