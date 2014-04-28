#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libxml2
version=2.9.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz
nwget http://xmlsoft.org/sources/libxml2-2.9.1.tar.gz
nwget http://www.w3.org/XML/Test/xmlts20130923.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libxml2-2.9.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar xf ../xmlts20130923.tar.gz

./configure --prefix=/usr --disable-static --with-history 
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
