#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=keyutils
version=1.5.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://people.redhat.com/~dhowells/keyutils/keyutils-1.5.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" keyutils-1.5.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make NO_ARLIB=1 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
