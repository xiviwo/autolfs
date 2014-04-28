#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=expect
version=5.45
export MAKEFLAGS='-j 4'
download()
{
nwget http://prdownloads.sourceforge.net/expect/expect5.45.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" expect5.45.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include 
make

make install 
ln -svf expect5.45/libexpect5.45.so /usr/lib


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
