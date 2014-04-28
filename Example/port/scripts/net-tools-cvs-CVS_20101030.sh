#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=net-tools-cvs
version=CVS_20101030
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/net-tools-CVS_20101030-remove_dups-1.patch
nwget ftp://anduin.linuxfromscratch.org/BLFS/svn/n/net-tools-CVS_20101030.tar.gz
nwget http://anduin.linuxfromscratch.org/sources/BLFS/svn/n/net-tools-CVS_20101030.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" net-tools-CVS_20101030.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../net-tools-CVS_20101030-remove_dups-1.patch 

yes "" | make config 
make

make update


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
