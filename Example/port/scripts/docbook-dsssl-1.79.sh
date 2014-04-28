#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=docbook-dsssl
version=1.79
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/docbook-dsssl-1.79.tar.bz2
nwget http://downloads.sourceforge.net/docbook/docbook-dsssl-1.79.tar.bz2
nwget http://downloads.sourceforge.net/docbook/docbook-dsssl-doc-1.79.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" docbook-dsssl-1.79.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../docbook-dsssl-doc-1.79.tar.bz2 --strip-components=1

install -v -m755 bin/collateindex.pl /usr/bin                      
install -v -m644 bin/collateindex.pl.1 /usr/share/man/man1         
install -v -d -m755 /usr/share/sgml/docbook/dsssl-stylesheets-1.79 
cp -v -R * /usr/share/sgml/docbook/dsssl-stylesheets-1.79          

install-catalog --add /etc/sgml/dsssl-docbook-stylesheets.cat /usr/share/sgml/docbook/dsssl-stylesheets-1.79/catalog         

install-catalog --add /etc/sgml/dsssl-docbook-stylesheets.cat /usr/share/sgml/docbook/dsssl-stylesheets-1.79/common/catalog  

install-catalog --add /etc/sgml/sgml-docbook.cat /etc/sgml/dsssl-docbook-stylesheets.cat

cd /usr/share/sgml/docbook/dsssl-stylesheets-1.79/doc/testdata

openjade -t rtf -d jtest.dsl jtest.sgm

onsgmls -sv test.sgm

openjade -t rtf -d /usr/share/sgml/docbook/dsssl-stylesheets-1.79/print/docbook.dsl test.sgm

openjade -t sgml -d /usr/share/sgml/docbook/dsssl-stylesheets-1.79/html/docbook.dsl test.sgm

rm jtest.rtf test.rtf c1.htm


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
