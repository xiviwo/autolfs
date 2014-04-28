#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pycairo
version=1.10.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://cairographics.org/releases/pycairo-1.10.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" pycairo-1.10.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
PYTHON=/usr/bin/python3 ./waf configure --prefix=/usr 
./waf build

./waf install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
