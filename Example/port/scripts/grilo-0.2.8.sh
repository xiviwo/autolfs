#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=grilo
version=0.2.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/grilo/0.2/grilo-0.2.8.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/grilo/0.2/grilo-0.2.8.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" grilo-0.2.8.tar.xz
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
