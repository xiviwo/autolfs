#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=psutils-p17
version=p17
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.knackered.org/pub/psutils/psutils-p17.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" psutils-p17.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed 's@/usr/local@/usr@g' Makefile.unix > Makefile 
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
