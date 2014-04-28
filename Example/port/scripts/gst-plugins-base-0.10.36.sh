#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gst-plugins-base
version=0.10.36
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/gst-plugins-base/0.10/gst-plugins-base-0.10.36.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gst-plugins-base-0.10.36.tar.xz
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
