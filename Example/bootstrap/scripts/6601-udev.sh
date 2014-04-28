#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=systemd
version=208
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" systemd-208.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xvf ../udev-lfs-208-3.tar.bz2

ln -svf /tools/include/blkid /usr/include
ln -svf /tools/include/uuid  /usr/include
export LD_LIBRARY_PATH=/tools/lib

make -f udev-lfs-208-3/Makefile.lfs

make -f udev-lfs-208-3/Makefile.lfs install

build/udevadm hwdb --update

bash udev-lfs-208-3/init-net-rules.sh

rm -fv /usr/include/{uuid,blkid}
unset LD_LIBRARY_PATH

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
