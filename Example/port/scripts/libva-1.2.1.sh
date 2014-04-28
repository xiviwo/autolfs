#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libva
version=1.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/libva-intel-driver-1.2.2.tar.bz2
nwget http://www.freedesktop.org/software/vaapi/releases/libva/libva-1.2.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libva-1.2.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure $XORG_CONFIG 
make

make install

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
