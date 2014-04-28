#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=automoc4
version=0.9.88
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/automoc4/0.9.88/automoc4-0.9.88.tar.bz2
nwget ftp://ftp.kde.org/pub/kde/stable/automoc4/0.9.88/automoc4-0.9.88.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" automoc4-0.9.88.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -Wno-dev .. 
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
