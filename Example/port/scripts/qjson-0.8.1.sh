#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qjson
version=0.8.1
export MAKEFLAGS='-j 1'
download()
{
nwget http://downloads.sourceforge.net/qjson/qjson-0.8.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" qjson-0.8.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX=$QTDIR -DCMAKE_BUILD_TYPE=Release .. 
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
