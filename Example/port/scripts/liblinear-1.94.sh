#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=liblinear
version=1.94
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.csie.ntu.edu.tw/~cjlin/liblinear/oldfiles/liblinear-1.94.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" liblinear-1.94.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make lib

install -vm644 linear.h /usr/include 
install -vm755 liblinear.so.1 /usr/lib 
ln -sfv liblinear.so.1 /usr/lib/liblinear.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
