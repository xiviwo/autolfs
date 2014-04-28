#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=baobab
version=3.10.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/baobab/3.10/baobab-3.10.1.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/baobab/3.10/baobab-3.10.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" baobab-3.10.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
