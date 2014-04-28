#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libgusb
version=0.1.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://people.freedesktop.org/~hughsient/releases/libgusb-0.1.6.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libgusb-0.1.6.tar.xz
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
