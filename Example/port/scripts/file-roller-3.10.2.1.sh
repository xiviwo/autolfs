#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=file-roller
version=3.10.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/file-roller/3.10/file-roller-3.10.2.1.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/file-roller/3.10/file-roller-3.10.2.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" file-roller-3.10.2.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-packagekit --disable-static 
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
