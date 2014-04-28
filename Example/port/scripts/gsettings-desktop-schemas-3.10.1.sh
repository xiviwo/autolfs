#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gsettings-desktop-schemas
version=3.10.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.10/gsettings-desktop-schemas-3.10.1.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/gsettings-desktop-schemas/3.10/gsettings-desktop-schemas-3.10.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gsettings-desktop-schemas-3.10.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
