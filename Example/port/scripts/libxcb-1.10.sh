#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libxcb
version=1.10
export MAKEFLAGS='-j 4'
download()
{
nwget http://xcb.freedesktop.org/dist/libxcb-1.10.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libxcb-1.10.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -e "s/pthread-stubs//" -i configure.ac 
autoreconf -fiv 
./configure $XORG_CONFIG --docdir='${datadir}'/doc/libxcb-1.10 --enable-xinput --enable-xkb 
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
