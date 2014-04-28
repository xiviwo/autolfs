#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rep-gtk
version=0.90.8.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.tuxfamily.org/librep/rep-gtk/rep-gtk-0.90.8.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" rep-gtk-0.90.8.1.tar.xz
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
