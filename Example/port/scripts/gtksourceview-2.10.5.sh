#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gtksourceview
version=2.10.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnome.org/pub/gnome/sources/gtksourceview/2.10/gtksourceview-2.10.5.tar.gz
nwget http://ftp.gnome.org/pub/gnome/sources/gtksourceview/2.10/gtksourceview-2.10.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" gtksourceview-2.10.5.tar.gz
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
