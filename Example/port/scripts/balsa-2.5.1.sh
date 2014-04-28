#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=balsa
version=2.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://pawsa.fedorapeople.org/balsa/balsa-2.5.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" balsa-2.5.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "/(HAVE_CONFIG_H)/i #include <glib-2.0/glib.h>" src/main-window.c 

./configure --prefix=/usr --sysconfdir=/etc/gnome --localstatedir=/var/lib --with-rubrica --without-html-widget --without-libnotify --without-nm --without-gtkspell       
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
