#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=w3m
version=0.5.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/w3m/w3m-0.5.3.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/w3m-0.5.3-bdwgc72-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" w3m-0.5.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../w3m-0.5.3-bdwgc72-1.patch 
sed -i 's/file_handle/file_foo/' istream.{c,h} 
sed -i 's#gdk-pixbuf-xlib-2.0#& x11#' configure 

./configure --prefix=/usr --sysconfdir=/etc 
make

make install 
install -v -m644 -D doc/keymap.default /etc/w3m/keymap 
install -v -m644    doc/menu.default /etc/w3m/menu 
install -v -m755 -d /usr/share/doc/w3m-0.5.3 
install -v -m644    doc/{HISTORY,READ*,keymap.*,menu.*,*.html} /usr/share/doc/w3m-0.5.3


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
