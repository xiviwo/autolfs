#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=hicolor-icon-theme
version=0.12
export MAKEFLAGS='-j 4'
download()
{
nwget http://icon-theme.freedesktop.org/releases/hicolor-icon-theme-0.12.tar.gz
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/hicolor-icon-theme-0.12.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" hicolor-icon-theme-0.12.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
