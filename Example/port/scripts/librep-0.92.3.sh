#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=librep
version=0.92.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.tuxfamily.org/librep/librep-0.92.3.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" librep-0.92.3.tar.xz
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
