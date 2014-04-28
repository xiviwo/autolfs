#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fontconfig
version=2.11.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" fontconfig-2.11.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --docdir=/usr/share/doc/fontconfig-2.11.0 --disable-docs --disable-static     
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
