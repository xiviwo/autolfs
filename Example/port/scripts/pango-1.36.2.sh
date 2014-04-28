#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pango
version=1.36.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/pango/1.36/pango-1.36.2.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/pango/1.36/pango-1.36.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" pango-1.36.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
make

make install

pango-querymodules --update-cache


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
