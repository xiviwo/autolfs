#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=nettle
version=2.7.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz
nwget ftp://ftp.gnu.org/gnu/nettle/nettle-2.7.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" nettle-2.7.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

sed -i '/^install-here/ s/install-static//' Makefile

make install 
chmod -v 755 /usr/lib/libhogweed.so.2.5 /usr/lib/libnettle.so.4.7 
install -v -m755 -d /usr/share/doc/nettle-2.7.1 
install -v -m644 nettle.html /usr/share/doc/nettle-2.7.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
