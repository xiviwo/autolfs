#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=boost
version=1.55.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/boost/boost_1_55_0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" boost_1_55_0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./bootstrap.sh --prefix=/usr 
./b2 stage threading=multi link=shared

./b2 install threading=multi link=shared


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
