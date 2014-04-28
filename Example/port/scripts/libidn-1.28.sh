#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libidn
version=1.28
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/libidn/libidn-1.28.tar.gz
nwget http://ftp.gnu.org/gnu/libidn/libidn-1.28.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libidn-1.28.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 

find doc -name "Makefile*" -delete            
rm -rf -v doc/{gdoc,idn.1,stamp-vti,man,texi} 
mkdir -pv       /usr/share/doc/libidn-1.28     
cp -r -v doc/* /usr/share/doc/libidn-1.28


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
