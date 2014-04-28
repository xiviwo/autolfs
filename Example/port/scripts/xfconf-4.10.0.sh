#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfconf
version=4.10.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/xfconf/4.10/xfconf-4.10.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfconf-4.10.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
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
