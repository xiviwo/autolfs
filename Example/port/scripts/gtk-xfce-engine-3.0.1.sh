#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gtk-xfce-engine
version=3.0.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/gtk-xfce-engine/3.0/gtk-xfce-engine-3.0.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gtk-xfce-engine-3.0.1.tar.bz2
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
