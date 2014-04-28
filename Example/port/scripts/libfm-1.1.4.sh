#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libfm
version=1.1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/pcmanfm/libfm-1.1.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libfm-1.1.4.tar.xz
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
