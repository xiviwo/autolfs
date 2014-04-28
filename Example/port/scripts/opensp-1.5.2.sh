#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=opensp
version=1.5.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/openjade/OpenSP-1.5.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" OpenSP-1.5.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's/32,/253,/' lib/Syntax.cxx 
sed -i 's/LITLEN          240 /LITLEN          8092/' unicode/{gensyntax.pl,unicode.syn} 

./configure --prefix=/usr --disable-static --disable-doc-build --enable-default-catalog=/etc/sgml/catalog --enable-http --enable-default-search-path=/usr/share/sgml 

make pkgdatadir=/usr/share/sgml/OpenSP-1.5.2

make pkgdatadir=/usr/share/sgml/OpenSP-1.5.2 install 
ln -v -sf onsgmls /usr/bin/nsgmls 
ln -v -sf osgmlnorm /usr/bin/sgmlnorm 
ln -v -sf ospam /usr/bin/spam 
ln -v -sf ospcat /usr/bin/spcat 
ln -v -sf ospent /usr/bin/spent 
ln -v -sf osx /usr/bin/sx 
ln -v -sf osx /usr/bin/sgml2xml 
ln -v -sf libosp.so /usr/lib/libsp.so


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
