#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libunistring
version=0.9.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/libunistring/libunistring-0.9.3.tar.gz
nwget http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libunistring-0.9.3.tar.gz
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
