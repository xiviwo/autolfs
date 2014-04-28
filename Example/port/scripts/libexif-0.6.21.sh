#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libexif
version=0.6.21
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libexif/libexif-0.6.21.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libexif-0.6.21.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-doc-dir=/usr/share/doc/libexif-0.6.21 --disable-static 
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
