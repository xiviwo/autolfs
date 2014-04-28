#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=icu
version=52.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.icu-project.org/files/icu4c/52.1/icu4c-52_1-src.tgz

}
unpack()
{
preparepack "$pkgname" "$version" icu4c-52_1-src.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd source 
CXX=g++ ./configure --prefix=/usr 
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
