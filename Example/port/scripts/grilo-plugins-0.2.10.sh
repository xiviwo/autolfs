#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=grilo-plugins
version=0.2.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/grilo-plugins/0.2/grilo-plugins-0.2.10.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/grilo-plugins/0.2/grilo-plugins-0.2.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" grilo-plugins-0.2.10.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-pocket 
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
