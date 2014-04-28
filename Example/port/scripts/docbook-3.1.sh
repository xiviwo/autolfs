#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=docbook
version=3.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.kde.org/pub/kde/devel/docbook/SOURCES/docbk31.zip
nwget http://www.docbook.org/sgml/3.1/docbk31.zip

}
unpack()
{
preparepack "$pkgname" "$version" docbk31.zip
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e '/ISO 8879/d' -e 's|DTDDECL "-//OASIS//DTD DocBook V3.1//EN"|SGMLDECL|g' docbook.cat

install -v -d -m755 /usr/share/sgml/docbook/sgml-dtd-3.1 
chown -R root:root . 
install -v docbook.cat /usr/share/sgml/docbook/sgml-dtd-3.1/catalog 
cp -v -af *.dtd *.mod *.dcl /usr/share/sgml/docbook/sgml-dtd-3.1 

install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat /usr/share/sgml/docbook/sgml-dtd-3.1/catalog 

install-catalog --add /etc/sgml/sgml-docbook-dtd-3.1.cat /etc/sgml/sgml-docbook.cat

cat >> /usr/share/sgml/docbook/sgml-dtd-3.1/catalog << "EOF"
  -- Begin Single Major Version catalog changes --

PUBLIC "-//Davenport//DTD DocBook V3.0//EN" "docbook.dtd"

  -- End Single Major Version catalog changes --
EOF


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
