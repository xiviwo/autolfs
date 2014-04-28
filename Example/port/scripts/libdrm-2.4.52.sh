#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdrm
version=2.4.52
export MAKEFLAGS='-j 4'
download()
{
nwget http://dri.freedesktop.org/libdrm/libdrm-2.4.52.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libdrm-2.4.52.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -e "/pthread-stubs/d" -i configure.ac 
autoreconf -fiv 
./configure --prefix=/usr --enable-udev 
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
