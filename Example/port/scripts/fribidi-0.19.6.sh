#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fribidi
version=0.19.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://fribidi.org/download/fribidi-0.19.6.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" fribidi-0.19.6.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s|glib/gstrfuncs\.h|glib.h|" charset/fribidi-char-sets.c 
sed -i "s|glib/gmem\.h|glib.h|"      lib/mem.h                   
./configure --prefix=/usr                                        
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
