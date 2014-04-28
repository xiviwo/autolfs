#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=goffice
version=0.10.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/goffice/0.10/goffice-0.10.10.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/goffice/0.10/goffice-0.10.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" goffice-0.10.10.tar.xz
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
