#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=opus
version=1.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" opus-1.1.tar.gz
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
