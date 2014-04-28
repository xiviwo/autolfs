#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=exiv2
version=0.24
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.exiv2.org/exiv2-0.24.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" exiv2-0.24.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
chmod -v 755 /usr/lib/libexiv2.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
