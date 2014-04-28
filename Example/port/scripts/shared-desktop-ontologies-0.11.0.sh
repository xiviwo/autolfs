#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=shared-desktop-ontologies
version=0.11.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/oscaf/shared-desktop-ontologies-0.11.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" shared-desktop-ontologies-0.11.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=$KDE_PREFIX -Wno-dev ..

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
