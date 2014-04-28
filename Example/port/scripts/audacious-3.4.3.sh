#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=audacious
version=3.4.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://distfiles.audacious-media-player.org/audacious-3.4.3.tar.bz2
nwget http://distfiles.audacious-media-player.org/audacious-plugins-3.4.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" audacious-3.4.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
TPUT=/bin/true ./configure --prefix=/usr --with-buildstamp="BLFS" 
make

make install

TPUT=/bin/true ./configure --prefix=/usr 
make

make install

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
