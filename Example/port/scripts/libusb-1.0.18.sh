#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libusb
version=1.0.18
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libusb/libusb-1.0.18.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libusb-1.0.18.tar.bz2
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
