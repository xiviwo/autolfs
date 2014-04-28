#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=agg
version=2.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.antigrain.com/agg-2.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" agg-2.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's:  -L@x_libraries@::' src/platform/X11/Makefile.am 
sed -i '/^AM_C_PROTOTYPES/d'   configure.in                 

bash autogen.sh --prefix=/usr --disable-static 
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
