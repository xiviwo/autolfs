#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libnl
version=3.2.24
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.carisma.slowglass.com/~tgr/libnl/files/libnl-3.2.24.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libnl-3.2.24.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-static 
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
