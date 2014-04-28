#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=harfbuzz
version=0.9.26
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.26.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" harfbuzz-0.9.26.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-gobject 
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
