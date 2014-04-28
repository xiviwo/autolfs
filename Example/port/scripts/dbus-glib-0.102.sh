#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=dbus-glib
version=0.102
export MAKEFLAGS='-j 4'
download()
{
nwget http://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.102.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" dbus-glib-0.102.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-static 
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
