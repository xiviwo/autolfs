#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=thunar
version=1.6.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/thunar/1.6/Thunar-1.6.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" Thunar-1.6.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --docdir=/usr/share/doc/Thunar-1.6.3 
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
