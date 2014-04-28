#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gmime
version=2.6.19
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gmime/2.6/gmime-2.6.19.tar.xz
nwget http://ftp.gnome.org/pub/gnome/sources/gmime/2.6/gmime-2.6.19.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gmime-2.6.19.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
