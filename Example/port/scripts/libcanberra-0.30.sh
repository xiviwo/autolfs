#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libcanberra
version=0.30
export MAKEFLAGS='-j 4'
download()
{
nwget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libcanberra-0.30.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-oss 
make

make docdir=/usr/share/doc/libcanberra-0.30 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
