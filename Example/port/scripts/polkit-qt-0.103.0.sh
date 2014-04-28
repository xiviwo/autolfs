#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=polkit-qt
version=0.103.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.kde.org/pub/kde/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2
nwget http://download.kde.org/stable/apps/KDE4.x/admin/polkit-qt-1-0.103.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" polkit-qt-1-0.103.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

CMAKE_PREFIX_PATH=$QTDIR cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -Wno-dev .. 
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
