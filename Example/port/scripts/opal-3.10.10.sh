#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=opal
version=3.10.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/opal-3.10.10-ffmpeg2-1.patch
nwget http://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz
nwget ftp://ftp.gnome.org/pub/gnome/sources/opal/3.10/opal-3.10.10.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" opal-3.10.10.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../opal-3.10.10-ffmpeg2-1.patch 

./configure --prefix=/usr 
make

make install 
chmod -v 644 /usr/lib/libopal_s.a


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
