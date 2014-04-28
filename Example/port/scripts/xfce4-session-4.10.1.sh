#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfce4-session
version=4.10.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/xfce4-session/4.10/xfce4-session-4.10.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfce4-session-4.10.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-legacy-sm 
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
