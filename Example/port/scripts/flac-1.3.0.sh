#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=flac
version=1.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/flac/flac-1.3.0.tar.xz
nwget ftp://downloads.xiph.org/pub/xiph/releases/flac/flac-1.3.0.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" flac-1.3.0.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-thorough-tests 
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
