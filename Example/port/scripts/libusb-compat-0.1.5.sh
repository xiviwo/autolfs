#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libusb-compat
version=0.1.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libusb/libusb-compat-0.1.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libusb-compat-0.1.5.tar.bz2
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
