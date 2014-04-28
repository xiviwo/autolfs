#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=zip
version=3.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/infozip/zip30.tar.gz
nwget ftp://ftp.info-zip.org/pub/infozip/src/zip30.tgz

}
unpack()
{
preparepack "$pkgname" "$version" zip30.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make -f unix/Makefile generic_gcc

make prefix=/usr MANDIR=/usr/share/man/man1 -f unix/Makefile install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
