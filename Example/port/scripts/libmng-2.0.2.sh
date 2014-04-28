#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libmng
version=2.0.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libmng/libmng-2.0.2.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" libmng-2.0.2.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s:#include <jpeg:#include <stdio.h>\n&:" libmng_types.h 

./configure --prefix=/usr --disable-static 
make

make install 

install -v -m755 -d        /usr/share/doc/libmng-2.0.2 
install -v -m644 doc/*.txt /usr/share/doc/libmng-2.0.2


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
