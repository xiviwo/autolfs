#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=clutter
version=1.16.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/clutter/1.16/clutter-1.16.4.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/clutter/1.16/clutter-1.16.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" clutter-1.16.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --enable-egl-backend 
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
