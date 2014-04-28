#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfce4-mixer
version=4.10.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/apps/xfce4-mixer/4.10/xfce4-mixer-4.10.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfce4-mixer-4.10.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
