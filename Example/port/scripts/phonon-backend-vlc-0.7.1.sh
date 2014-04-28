#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=phonon-backend-vlc
version=0.7.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/phonon/phonon-backend-vlc/0.7.1/phonon-backend-vlc-0.7.1.tar.xz
nwget ftp://ftp.kde.org/pub/kde/stable/phonon/phonon-backend-vlc/0.7.1/phonon-backend-vlc-0.7.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" phonon-backend-vlc-0.7.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -Wno-dev .. 
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
