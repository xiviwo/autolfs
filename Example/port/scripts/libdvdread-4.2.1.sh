#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdvdread
version=4.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://dvdnav.mplayerhq.hu/releases/libdvdread-4.2.1.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libdvdread-4.2.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./autogen.sh --prefix=/usr 
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
