#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=iso-codes
version=3.51
export MAKEFLAGS='-j 4'
download()
{
nwget http://pkg-isocodes.alioth.debian.org/downloads/iso-codes-3.51.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" iso-codes-3.51.tar.xz
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
