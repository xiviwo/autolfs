#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tcl
version=8.6.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/tcl/tcl8.6.1-src.tar.gz
nwget http://downloads.sourceforge.net/tcl/tcl8.6.1-html.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" tcl8.6.1-src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../tcl8.6.1-html.tar.gz --strip-components=1

cd unix 
./configure --prefix=/usr --without-tzdata --mandir=/usr/share/man $([ $(uname -m) = x86_64 ] && echo --enable-64bit) 
make 

sed -e "s@^\(TCL_SRC_DIR='\).*@\1/usr/include'@" -e "/TCL_B/s@='\(-L\)\?.*unix@='\1/usr/lib@" -i tclConfig.sh

make install 
make install-private-headers 
ln -v -sf tclsh8.6 /usr/bin/tclsh 
chmod -v 755 /usr/lib/libtcl8.6.so

mkdir -pv -p /usr/share/doc/tcl-8.6.1 
cp -v -r  ../html/* /usr/share/doc/tcl-8.6.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
