#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libass
version=0.10.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://libass.googlecode.com/files/libass-0.10.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libass-0.10.2.tar.xz
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
