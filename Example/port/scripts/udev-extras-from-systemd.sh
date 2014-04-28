#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=systemd
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/systemd/systemd-208.tar.xz


}
unpack()
{
preparepack "$pkgname" "$version" systemd-208.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
UDEV=208-3
tar -xf ../udev-lfs-$UDEV.tar.bz2


make -f udev-lfs-$UDEV/Makefile.lfs keymap

make -f udev-lfs-$UDEV/Makefile.lfs install-keymap

make -f udev-lfs-$UDEV/Makefile.lfs gudev

make -f udev-lfs-$UDEV/Makefile.lfs install-gudev

make -f udev-lfs-$UDEV/Makefile.lfs gir-data

make -f udev-lfs-$UDEV/Makefile.lfs install-gir-data


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
