#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gnome-terminal
version=3.10.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gnome-terminal/3.10/gnome-terminal-3.10.2.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gnome-terminal/3.10/gnome-terminal-3.10.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gnome-terminal-3.10.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --disable-migration --with-nautilus-extension 
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
