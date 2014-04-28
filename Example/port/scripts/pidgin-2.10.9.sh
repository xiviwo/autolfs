#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pidgin
version=2.10.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/pidgin/pidgin-2.10.9.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" pidgin-2.10.9.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-avahi --disable-dbus --disable-gtkspell --disable-gstreamer --disable-meanwhile --disable-idn --disable-nm --disable-vv --disable-tcl 
make

make install 
mkdir -pv -pv /usr/share/doc/pidgin-2.10.9 
cp -v README doc/gtkrc-2.0 /usr/share/doc/pidgin-2.10.9

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
