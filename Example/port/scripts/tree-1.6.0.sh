#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tree
version=1.6.0
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mama.indstate.edu/linux/tree/tree-1.6.0.tgz
nwget http://mama.indstate.edu/users/ice/tree/src/tree-1.6.0.tgz

}
unpack()
{
preparepack "$pkgname" "$version" tree-1.6.0.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make MANDIR=/usr/share/man/man1 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
