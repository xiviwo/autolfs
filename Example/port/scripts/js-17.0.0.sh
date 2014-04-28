#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=js
version=17.0.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz
nwget ftp://ftp.mozilla.org/pub/mozilla.org/js/mozjs17.0.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" mozjs17.0.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd js/src 
./configure --prefix=/usr --enable-readline --enable-threadsafe --with-system-ffi --with-system-nspr 
make

make install 
find /usr/include/js-17.0/ /usr/lib/libmozjs-17.0.a /usr/lib/pkgconfig/mozjs-17.0.pc -type f -exec chmod -v 644 {} \;


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
