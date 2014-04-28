#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=glib-networking
version=2.38.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/glib-networking/2.38/glib-networking-2.38.2.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/glib-networking/2.38/glib-networking-2.38.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" glib-networking-2.38.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-ca-certificates=/etc/ssl/ca-bundle.crt --disable-static                              
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
