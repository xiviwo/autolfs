#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libnice
version=0.1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://nice.freedesktop.org/releases/libnice-0.1.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libnice-0.1.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --without-gstreamer-0.10 
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
