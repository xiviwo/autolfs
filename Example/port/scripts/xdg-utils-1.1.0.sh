#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xdg-utils
version=1.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://portland.freedesktop.org/download/xdg-utils-1.1.0-rc1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" xdg-utils-1.1.0-rc1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
