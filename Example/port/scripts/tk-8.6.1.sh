#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tk
version=8.6.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/tcl/tk8.6.1-src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" tk8.6.1-src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd unix 
./configure --prefix=/usr --mandir=/usr/share/man $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 

make 

sed -e "s@^\(TK_SRC_DIR='\).*@\1/usr/include'@" -e "/TK_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" -i tkConfig.sh

make install 
make install-private-headers 
ln -v -sf wish8.6 /usr/bin/wish 
chmod -v 755 /usr/lib/libtk8.6.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
