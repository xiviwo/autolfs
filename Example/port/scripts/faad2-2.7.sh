#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=faad2
version=2.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/faad2-2.7-mp4ff-1.patch
nwget http://downloads.sourceforge.net/faac/faad2-2.7.tar.bz2
nwget http://www.nch.com.au/acm/sample.aac

}
unpack()
{
preparepack "$pkgname" "$version" faad2-2.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../faad2-2.7-mp4ff-1.patch 
sed -i "s:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:g" configure.in 
sed -i "s:man_MANS:man1_MANS:g" frontend/Makefile.am 
autoreconf -fi 
./configure --prefix=/usr --disable-static 
make

./frontend/faad -o sample.wav ../sample.aac

aplay sample.wav

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
