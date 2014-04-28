#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tumbler
version=0.1.29
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/xfce/tumbler/0.1/tumbler-0.1.29.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" tumbler-0.1.29.tar.bz2
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
