#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=grub
version=2.00
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" grub-2.00.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e '/gets is a/d' grub-core/gnulib/stdio.in.h

./configure --prefix=/usr --sbindir=/sbin --sysconfdir=/etc --disable-grub-emu-usb --disable-efiemu --disable-werror

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
