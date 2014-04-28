#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=redland
version=1.0.17
export MAKEFLAGS='-j 4'
download()
{
nwget http://download.librdf.org/source/redland-1.0.17.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" redland-1.0.17.tar.gz
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
