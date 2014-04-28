#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=popt
version=1.16
export MAKEFLAGS='-j 4'
download()
{
nwget http://rpm5.org/files/popt/popt-1.16.tar.gz
nwget ftp://anduin.linuxfromscratch.org/BLFS/svn/p/popt-1.16.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" popt-1.16.tar.gz
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
