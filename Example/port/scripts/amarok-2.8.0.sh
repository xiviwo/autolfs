#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=amarok
version=2.8.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/amarok/2.8.0/src/amarok-2.8.0.tar.bz2
nwget ftp://ftp.kde.org/pub/kde/stable/amarok/2.8.0/src/amarok-2.8.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" amarok-2.8.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_BUILD_TYPE=Release -DKDE4_BUILD_TESTS=OFF -Wno-dev .. 
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
