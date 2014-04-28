#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=vorbis-tools
version=1.4.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/vorbis/vorbis-tools-1.4.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" vorbis-tools-1.4.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-vcut --without-curl 
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
