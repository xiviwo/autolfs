#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cairomm
version=1.10.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://cairographics.org/releases/cairomm-1.10.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" cairomm-1.10.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
