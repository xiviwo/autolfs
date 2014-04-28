#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libjpeg-turbo
version=1.3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-1.3.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libjpeg-turbo-1.3.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man --with-jpeg8 --disable-static 
sed -i -e '/^docdir/ s/$/\/libjpeg-turbo-1.3.0/' -e '/^exampledir/ s/$/\/libjpeg-turbo-1.3.0/' Makefile 
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
