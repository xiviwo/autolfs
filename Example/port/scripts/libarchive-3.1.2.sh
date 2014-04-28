#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libarchive
version=3.1.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.libarchive.org/downloads/libarchive-3.1.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libarchive-3.1.2.tar.gz
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
