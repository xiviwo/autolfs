#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lame
version=3.99.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lame/lame-3.99.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lame-3.99.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --enable-mp3rtp --disable-static 
make

make pkghtmldir=/usr/share/doc/lame-3.99.5 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
