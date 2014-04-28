#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=thunar-volman
version=0.8.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/thunar-volman/0.8/thunar-volman-0.8.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" thunar-volman-0.8.0.tar.bz2
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
