#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gvfs
version=1.18.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gvfs/1.18/gvfs-1.18.3.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gvfs/1.18/gvfs-1.18.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gvfs-1.18.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-gphoto2 
make

make install

glib-compile-schemas /usr/share/glib-2.0/schemas


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
