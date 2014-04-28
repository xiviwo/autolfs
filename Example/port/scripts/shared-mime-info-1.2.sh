#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=shared-mime-info
version=1.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://freedesktop.org/~hadess/shared-mime-info-1.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" shared-mime-info-1.2.tar.xz
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
