#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=attica
version=0.4.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.kde.org/stable/attica/attica-0.4.2.tar.bz2
nwget ftp://ftp.kde.org/pub/kde/stable/attica/attica-0.4.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" attica-0.4.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_BUILD_TYPE=Release -DQT4_BUILD=ON -Wno-dev .. 
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
