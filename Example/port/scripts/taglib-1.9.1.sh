#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=taglib
version=1.9.1
export MAKEFLAGS='-j 4'
download()
{
nwget https://github.com/taglib/taglib/releases/download/v1.9.1/taglib-1.9.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" taglib-1.9.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd    build 

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
