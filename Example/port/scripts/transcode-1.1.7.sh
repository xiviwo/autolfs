#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=transcode
version=1.1.7
export MAKEFLAGS='-j 4'
download()
{
nwget https://bitbucket.org/france/transcode-tcforge/downloads/transcode-1.1.7.tar.bz2
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/transcode-1.1.7-ffmpeg2-1.patch
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/transcode-1.1.7.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" transcode-1.1.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s:#include <freetype/ftglyph.h>:#include FT_GLYPH_H:" filter/subtitler/load_font.c

sed -i 's|doc/transcode|&-$(PACKAGE_VERSION)|' $(find . -name Makefile.in -exec grep -l 'docsdir =' {} \;) 
patch -Np1 -i ../transcode-1.1.7-ffmpeg2-1.patch 
./configure --prefix=/usr --enable-alsa --enable-libmpeg2 
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
