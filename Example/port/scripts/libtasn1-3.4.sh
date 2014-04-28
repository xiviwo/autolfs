#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libtasn1
version=3.4
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/libtasn1/libtasn1-3.4.tar.gz
nwget http://ftp.gnu.org/gnu/libtasn1/libtasn1-3.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libtasn1-3.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
