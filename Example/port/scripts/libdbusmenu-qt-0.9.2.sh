#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdbusmenu-qt
version=0.9.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://launchpad.net/libdbusmenu-qt/trunk/0.9.2/+download/libdbusmenu-qt-0.9.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libdbusmenu-qt-0.9.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -DCMAKE_BUILD_TYPE=Release -DWITH_DOC=OFF .. 
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
