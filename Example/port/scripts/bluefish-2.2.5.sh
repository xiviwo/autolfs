#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bluefish
version=2.2.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.bennewitz.com/bluefish/stable/source/bluefish-2.2.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" bluefish-2.2.5.tar.bz2
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
