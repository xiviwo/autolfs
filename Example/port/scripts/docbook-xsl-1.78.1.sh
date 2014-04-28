#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=docbook-xsl
version=1.78.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/docbook/docbook-xsl-doc-1.78.1.tar.bz2
nwget http://downloads.sourceforge.net/docbook/docbook-xsl-1.78.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" docbook-xsl-1.78.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../docbook-xsl-doc-1.78.1.tar.bz2 --strip-components=1

install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-1.78.1 

cp -v -R VERSION common eclipse epub extensions fo highlighting html htmlhelp images javahelp lib manpages params profiling roundtrip slides template tests tools webhelp website xhtml xhtml-1_1 /usr/share/xml/docbook/xsl-stylesheets-1.78.1 

ln -svf VERSION /usr/share/xml/docbook/xsl-stylesheets-1.78.1/VERSION.xsl 

install -v -m644 -D README /usr/share/doc/docbook-xsl-1.78.1/README.txt 
install -v -m644    RELEASE-NOTES* NEWS* /usr/share/doc/docbook-xsl-1.78.1

cp -v -R doc/* /usr/share/doc/docbook-xsl-1.78.1

if [ ! -d /etc/xml ]; then install -v -m755 -d /etc/xml; fi 
if [ ! -f /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi 

xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/1.78.1" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" /etc/xml/catalog 

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/1.78.1" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" /etc/xml/catalog 

xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/current" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" /etc/xml/catalog 

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/current" "/usr/share/xml/docbook/xsl-stylesheets-1.78.1" /etc/xml/catalog

xmlcatalog --noout --add "rewriteSystem" "http://docbook.sourceforge.net/release/xsl/<version>" "/usr/share/xml/docbook/xsl-stylesheets-<version>" /etc/xml/catalog 

xmlcatalog --noout --add "rewriteURI" "http://docbook.sourceforge.net/release/xsl/<version>" "/usr/share/xml/docbook/xsl-stylesheets-<version>" /etc/xml/catalog


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
