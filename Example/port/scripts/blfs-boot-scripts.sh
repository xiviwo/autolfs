#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=blfs-boot-scripts
version=
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/blfs/downloads/7.5/blfs-bootscripts-20140301.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" blfs-bootscripts-20140301.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
:
}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
