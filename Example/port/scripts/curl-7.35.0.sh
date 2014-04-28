#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=curl
version=7.35.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://curl.haxx.se/download/curl-7.35.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" curl-7.35.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --enable-threaded-resolver 
make

make install 
find docs \( -name "Makefile*" -o -name "*.1" -o -name "*.3" \) -exec rm {} \; 
install -v -d -m755 /usr/share/doc/curl-7.35.0 
cp -v -R docs/*     /usr/share/doc/curl-7.35.0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
