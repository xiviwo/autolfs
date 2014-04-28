#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=polkit-kde-agent
version=0.99.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/polkit-kde-agent-1-0.99.0-remember_password-1.patch
nwget ftp://ftp.kde.org/pub/kde/stable/apps/KDE4.x/admin/polkit-kde-agent-1-0.99.0.tar.bz2
nwget http://download.kde.org/stable/apps/KDE4.x/admin/polkit-kde-agent-1-0.99.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" polkit-kde-agent-1-0.99.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../polkit-kde-agent-1-0.99.0-remember_password-1.patch 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -Wno-dev .. 
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
