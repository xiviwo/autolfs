#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gst-plugins-ugly
version=1.2.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-1.2.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gst-plugins-ugly-1.2.3.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-package-name="GStreamer Ugly Plugins 1.2.3 BLFS" --with-package-origin="http://www.linuxfromscratch.org/blfs/view/svn/" 
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
