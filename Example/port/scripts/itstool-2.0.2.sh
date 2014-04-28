#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=itstool
version=2.0.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://files.itstool.org/itstool/itstool-2.0.2.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" itstool-2.0.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
