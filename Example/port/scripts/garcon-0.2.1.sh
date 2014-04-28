#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=garcon
version=0.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/garcon/0.2/garcon-0.2.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" garcon-0.2.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
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
