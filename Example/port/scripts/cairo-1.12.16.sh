#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cairo
version=1.12.16
export MAKEFLAGS='-j 4'
download()
{
nwget http://cairographics.org/releases/cairo-1.12.16.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" cairo-1.12.16.tar.xz
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
