#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=network-manager-applet
version=0.9.8.8
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.8.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/network-manager-applet/0.9/network-manager-applet-0.9.8.8.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" network-manager-applet-0.9.8.8.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-migration --disable-static 
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
