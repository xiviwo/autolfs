#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sbc
version=1.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.kernel.org/pub/linux/bluetooth/sbc-1.2.tar.xz
nwget ftp://www.kernel.org/pub/linux/bluetooth/sbc-1.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" sbc-1.2.tar.xz
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
