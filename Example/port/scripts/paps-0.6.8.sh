#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=paps
version=0.6.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/paps/paps-0.6.8.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/paps-0.6.8-freetype_fix-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" paps-0.6.8.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../paps-0.6.8-freetype_fix-1.patch 
./configure --prefix=/usr --mandir=/usr/share/man 
make

make install 
install -v -m755 -d                 /usr/share/doc/paps-0.6.8 
install -v -m644 doxygen-doc/html/* /usr/share/doc/paps-0.6.8


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
