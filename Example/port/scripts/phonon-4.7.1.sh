#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=phonon
version=4.7.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/phonon/4.7.1/phonon-4.7.1.tar.xz
nwget ftp://ftp.kde.org/pub/kde/stable/phonon/4.7.1/phonon-4.7.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" phonon-4.7.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib -DPHONON_INSTALL_QT_EXTENSIONS_INTO_SYSTEM_QT=TRUE -DDBUS_INTERFACES_INSTALL_DIR=/usr/share/dbus-1/interfaces -Wno-dev .. 
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
