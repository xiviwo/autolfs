#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rasqal
version=0.9.31
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.librdf.org/source/rasqal-0.9.31.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" rasqal-0.9.31.tar.gz
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
