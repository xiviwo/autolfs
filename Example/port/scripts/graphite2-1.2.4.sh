#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=graphite2
version=1.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/silgraphite/graphite2-1.2.4.tgz

}
unpack()
{
preparepack "$pkgname" "$version" graphite2-1.2.4.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd build 
cmake -DCMAKE_INSTALL_PREFIX=/usr .. 
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
