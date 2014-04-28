#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=apr
version=1.5.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.apache.org/dist/apr/apr-1.5.0.tar.bz2
nwget ftp://ftp.mirrorservice.org/sites/ftp.apache.org/apr/apr-1.5.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" apr-1.5.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --with-installbuilddir=/usr/share/apr-1/build 
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
