#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xine-ui
version=0.99.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/xine/xine-ui-0.99.7.tar.xz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/xine-ui-0.99.7-upstream_fix-1.patch
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/xine-ui-0.99.7.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" xine-ui-0.99.7.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../xine-ui-0.99.7-upstream_fix-1.patch

./configure --prefix=/usr 
make

make docsdir=/usr/share/doc/xine-ui-0.99.7 install

gtk-update-icon-cache 
update-desktop-database


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
