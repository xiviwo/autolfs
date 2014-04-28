#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=links
version=2.8
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/links-2.8.tar.bz2
nwget http://links.twibright.com/download/links-2.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" links-2.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --mandir=/usr/share/man 
make

make install 
install -v -d -m755 /usr/share/doc/links-2.8 
install -v -m644 doc/links_cal/* KEYS BRAILLE_HOWTO /usr/share/doc/links-2.8


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
