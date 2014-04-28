#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pixman
version=0.32.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://cairographics.org/releases/pixman-0.32.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" pixman-0.32.4.tar.gz
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
