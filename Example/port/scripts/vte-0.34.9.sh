#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=vte
version=0.34.9
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.9.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/vte/0.34/vte-0.34.9.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" vte-0.34.9.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-static --enable-introspection 
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
