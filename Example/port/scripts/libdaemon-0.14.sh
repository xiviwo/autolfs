#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdaemon
version=0.14
export MAKEFLAGS='-j 4'
download()
{
nwget http://0pointer.de/lennart/projects/libdaemon/libdaemon-0.14.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libdaemon-0.14.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make docdir=/usr/share/doc/libdaemon-0.14 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
