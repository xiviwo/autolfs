#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=speex
version=1.2rc1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.us.xiph.org/releases/speex/speex-1.2rc1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" speex-1.2rc1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/speex-1.2rc1 
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
