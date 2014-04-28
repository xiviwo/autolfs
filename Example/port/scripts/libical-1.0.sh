#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libical
version=1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/freeassociation/libical-1.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libical-1.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd build 

cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release .. 
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
