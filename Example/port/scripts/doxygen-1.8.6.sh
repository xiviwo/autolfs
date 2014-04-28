#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=doxygen
version=1.8.6
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.stack.nl/pub/doxygen/doxygen-1.8.6.src.tar.gz
nwget http://ftp.stack.nl/pub/doxygen/doxygen-1.8.6.src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" doxygen-1.8.6.src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make MAN1DIR=share/man/man1 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
