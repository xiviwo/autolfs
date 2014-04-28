#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=upower
version=0.9.23
export MAKEFLAGS='-j 4'
download()
{
nwget http://upower.freedesktop.org/releases/upower-0.9.23.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" upower-0.9.23.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --enable-deprecated --disable-static 
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
