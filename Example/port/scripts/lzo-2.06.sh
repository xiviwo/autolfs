#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lzo
version=2.06
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.oberhumer.com/opensource/lzo/download/lzo-2.06.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lzo-2.06.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-shared --disable-static --docdir=/usr/share/doc/lzo-2.06 
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
