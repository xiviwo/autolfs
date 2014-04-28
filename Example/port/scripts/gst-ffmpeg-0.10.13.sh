#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gst-ffmpeg
version=0.10.13
export MAKEFLAGS='-j 4'
download()
{
nwget http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gst-ffmpeg-0.10.13-gcc-4.7-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" gst-ffmpeg-0.10.13.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -p1 < ../gst-ffmpeg-0.10.13-gcc-4.7-1.patch 
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
