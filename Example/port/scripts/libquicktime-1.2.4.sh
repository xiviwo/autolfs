#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libquicktime
version=1.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libquicktime/libquicktime-1.2.4.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/libquicktime-1.2.4-ffmpeg2-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" libquicktime-1.2.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../libquicktime-1.2.4-ffmpeg2-1.patch 

./configure --prefix=/usr --enable-gpl --without-doxygen --docdir=/usr/share/doc/libquicktime-1.2.4
make

make install 
install -v -m755 -d /usr/share/doc/libquicktime-1.2.4 
install -v -m644    README doc/{*.txt,*.html,mainpage.incl} /usr/share/doc/libquicktime-1.2.4


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
