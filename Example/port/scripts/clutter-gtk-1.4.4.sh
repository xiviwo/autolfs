#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=clutter-gtk
version=1.4.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/clutter-gtk/1.4/clutter-gtk-1.4.4.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/clutter-gtk/1.4/clutter-gtk-1.4.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" clutter-gtk-1.4.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
