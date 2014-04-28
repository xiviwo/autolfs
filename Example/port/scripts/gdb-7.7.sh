#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gdb
version=7.7
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/gdb/gdb-7.7.tar.bz2
nwget http://ftp.gnu.org/gnu/gdb/gdb-7.7.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gdb-7.7.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-system-readline 
make

make -C gdb install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
