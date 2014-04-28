#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=akonadi
version=1.11.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.kde.org/pub/kde/stable/akonadi/src/akonadi-1.11.0.tar.bz2
nwget http://download.kde.org/stable/akonadi/src/akonadi-1.11.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" akonadi-1.11.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -DCMAKE_PREFIX_PATH=$QTDIR -DCMAKE_BUILD_TYPE=Release -DINSTALL_QSQLITE_IN_QT_PREFIX=TRUE -Wno-dev .. 
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
