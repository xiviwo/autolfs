#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gst-plugins-ugly
version=0.10.19
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gst-plugins-ugly-0.10.19-libcdio_fixes-1.patch
nwget http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-0.10.19.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gst-plugins-ugly-0.10.19.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../gst-plugins-ugly-0.10.19-libcdio_fixes-1.patch 
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
