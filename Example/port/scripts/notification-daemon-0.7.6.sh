#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=notification-daemon
version=0.7.6
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/notification-daemon/0.7/notification-daemon-0.7.6.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/notification-daemon/0.7/notification-daemon-0.7.6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" notification-daemon-0.7.6.tar.xz
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
