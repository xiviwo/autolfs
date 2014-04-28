#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=liba52
version=0.7.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://liba52.sourceforge.net/files/a52dec-0.7.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" a52dec-0.7.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man --enable-shared --disable-static CFLAGS="-g -O2 $([ $(uname -m) = x86_64 ] && echo -fPIC)" 
make

make install 
cp liba52/a52_internal.h /usr/include/a52dec 
install -v -m644 -D doc/liba52.txt /usr/share/doc/liba52-0.7.4/liba52.txt


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
