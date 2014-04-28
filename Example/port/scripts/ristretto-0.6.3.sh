#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ristretto
version=0.6.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/apps/ristretto/0.6/ristretto-0.6.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" ristretto-0.6.3.tar.bz2
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
