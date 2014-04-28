#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=usbutils
version=007
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz
nwget ftp://ftp.kernel.org/pub/linux/utils/usb/usbutils/usbutils-007.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" usbutils-007.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-zlib --datadir=/usr/share/misc 
make

make install 
mv -v /usr/sbin/update-usbids.sh /usr/sbin/update-usbids


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
