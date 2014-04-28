#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libvorbis
version=1.3.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libvorbis-1.3.4.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m644 doc/Vorbis* /usr/share/doc/libvorbis-1.3.4


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
