#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mpg123
version=1.18.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/mpg123/mpg123-1.18.0.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" mpg123-1.18.0.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-module-suffix=.so 
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
