#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libsamplerate
version=0.1.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.mega-nerd.com/SRC/libsamplerate-0.1.8.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libsamplerate-0.1.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make htmldocdir=/usr/share/doc/libsamplerate-0.1.8 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
