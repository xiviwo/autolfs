#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libwebp
version=0.4.0
export MAKEFLAGS='-j 4'
download()
{
nwget https://webp.googlecode.com/files/libwebp-0.4.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libwebp-0.4.0.tar.gz
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
