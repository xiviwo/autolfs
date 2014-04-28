#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=yasm
version=1.2.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" yasm-1.2.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's#) ytasm.*#)#' Makefile.in 
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
