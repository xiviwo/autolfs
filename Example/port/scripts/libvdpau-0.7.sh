#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libvdpau
version=0.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://people.freedesktop.org/~aplattner/vdpau/libvdpau-0.7.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libvdpau-0.7.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG 
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
