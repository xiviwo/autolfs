#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libtiff
version=4.0.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.remotesensing.org/libtiff/tiff-4.0.3.tar.gz
nwget http://download.osgeo.org/libtiff/tiff-4.0.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" tiff-4.0.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i '/glDrawPixels/a glFlush();' tools/tiffgt.c 
./configure --prefix=/usr --disable-static 
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
