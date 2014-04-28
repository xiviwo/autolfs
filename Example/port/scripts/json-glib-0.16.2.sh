#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=json-glib
version=0.16.2
export MAKEFLAGS='-j 1'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/json-glib/0.16/json-glib-0.16.2.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/json-glib/0.16/json-glib-0.16.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" json-glib-0.16.2.tar.xz
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
