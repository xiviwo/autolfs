#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ntfs-3g
version=3g
export MAKEFLAGS='-j 4'
download()
{
nwget http://tuxera.com/opensource/ntfs-3g_ntfsprogs-2013.1.13.tgz

}
unpack()
{
preparepack "$pkgname" "$version" ntfs-3g_ntfsprogs-2013.1.13.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
ln -svf ../bin/ntfs-3g /sbin/mount.ntfs 
ln -svf /usr/share/man/man8/{ntfs-3g,mount.ntfs}.8

chmod -v 4755 /sbin/mount.ntfs

chmod -v 777 /mnt/usb


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
