#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=kdelibs
version=4.12.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/kdelibs-4.12.2.tar.xz
nwget http://download.kde.org/stable/4.12.2/src/kdelibs-4.12.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" kdelibs-4.12.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s@{SYSCONF_INSTALL_DIR}/xdg/menus@& RENAME kde-applications.menu@" kded/CMakeLists.txt 

sed -i "s@applications.menu@kde-&@" kded/kbuildsycoca.cpp

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -DDOCBOOKXML_CURRENTDTD_DIR=/usr/share/xml/docbook/xml-dtd-4.5 -Wno-dev .. 
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
