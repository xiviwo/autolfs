#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libxslt
version=1.1.28
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://xmlsoft.org/libxslt/libxslt-1.1.28.tar.gz
nwget http://xmlsoft.org/sources/libxslt-1.1.28.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libxslt-1.1.28.tar.gz
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
