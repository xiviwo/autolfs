#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfdesktop
version=4.10.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/xfdesktop/4.10/xfdesktop-4.10.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfdesktop-4.10.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
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
