#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=json-c
version=0.11
export MAKEFLAGS='-j 1'
download()
{
nwget https://s3.amazonaws.com/json-c_releases/releases/json-c-0.11.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" json-c-0.11.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make -j1

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
