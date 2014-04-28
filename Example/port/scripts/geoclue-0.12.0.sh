#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=geoclue
version=0.12.0
export MAKEFLAGS='-j 4'
download()
{
nwget https://launchpad.net/geoclue/trunk/0.12/+download/geoclue-0.12.0.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/geoclue-0.12.0-gpsd_fix-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" geoclue-0.12.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../geoclue-0.12.0-gpsd_fix-1.patch 
sed -i "s@ -Werror@@" configure 
sed -i "s@libnm_glib@libnm-glib@g" configure 
sed -i "s@geoclue/libgeoclue.la@& -lgthread-2.0@g" providers/skyhook/Makefile.in 
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
