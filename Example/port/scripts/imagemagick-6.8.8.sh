#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=imagemagick
version=6.8.8
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.8.8-6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" ImageMagick-6.8.8-6.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --with-modules --with-perl --disable-static  
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
