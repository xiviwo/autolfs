#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gegl
version=0.2.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gimp.org/pub/gegl/0.2/gegl-0.2.0.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gegl-0.2.0-ffmpeg2-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" gegl-0.2.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../gegl-0.2.0-ffmpeg2-1.patch 
./configure --prefix=/usr 
LC_ALL=en_US make

make install 
install -v -m644 docs/*.{css,html} /usr/share/gtk-doc/html/gegl 
install -d -v -m755 /usr/share/gtk-doc/html/gegl/images 
install -v -m644 docs/images/* /usr/share/gtk-doc/html/gegl/images


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
