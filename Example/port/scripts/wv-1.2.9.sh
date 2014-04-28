#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=wv
version=1.2.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.abisource.com/downloads/wv/1.2.9/wv-1.2.9.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" wv-1.2.9.tar.gz
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
