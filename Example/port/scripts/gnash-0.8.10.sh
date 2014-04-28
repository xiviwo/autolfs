#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gnash
version=0.8.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/gnash-0.8.10-CVE-2012-1175-1.patch
nwget http://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2
nwget ftp://ftp.gnu.org/pub/gnu/gnash/0.8.10/gnash-0.8.10.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gnash-0.8.10.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../gnash-0.8.10-CVE-2012-1175-1.patch 
sed -i '/^LIBS/s/\(.*\)/\1 -lboost_system/' gui/Makefile.in utilities/Makefile.in 
sed -i "/DGifOpen/s:Data:&, NULL:" libbase/GnashImageGif.cpp 
sed -i '/#include <csignal>/a\#include <unistd.h>' plugin/klash4/klash_part.cpp 
./configure --prefix=/usr --sysconfdir=/etc --with-npapi-incl=/usr/include/npapi-sdk --enable-media=gst --with-npapi-plugindir=/usr/lib/mozilla/plugins --without-gconf 
make

make install 
make install-plugin


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
