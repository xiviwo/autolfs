#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=kdepim
version=4.12.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/4.12.2/src/kdepim-4.12.2.tar.xz
nwget ftp://ftp.kde.org/pub/kde/stable/4.12.2/src/kdepim-4.12.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" kdepim-4.12.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DSYSCONF_INSTALL_DIR=/etc -DCMAKE_BUILD_TYPE=Release -Wno-dev .. 
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
