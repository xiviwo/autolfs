#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ffmpeg
version=2.1.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://ffmpeg.org/releases/ffmpeg-2.1.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" ffmpeg-2.1.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/-lflite"/-lflite -lasound"/' configure 
./configure --prefix=/usr --enable-gpl --enable-version3 --enable-nonfree --disable-static --enable-shared --disable-debug --enable-libass --enable-libfdk-aac --enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-x11grab     
make 
gcc tools/qt-faststart.c -o tools/qt-faststart

make install 
install -v -m755    tools/qt-faststart /usr/bin 
install -v -m755 -d /usr/share/doc/ffmpeg 
install -v -m644    doc/*.txt /usr/share/doc/ffmpeg

install -v -m644 doc/*.html /usr/share/doc/ffmpeg


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
