#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openjade
version=1.3.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/openjade-1.3.2-gcc_4.6-1.patch
nwget http://downloads.sourceforge.net/openjade/openjade-1.3.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" openjade-1.3.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../openjade-1.3.2-gcc_4.6-1.patch

sed -i -e '/getopts/{N;s#&G#g#;s#do .getopts.pl.;##;}' -e '/use POSIX/ause Getopt::Std;' msggen.pl

./configure --prefix=/usr --mandir=/usr/share/man --enable-http --disable-static --enable-default-catalog=/etc/sgml/catalog --enable-default-search-path=/usr/share/sgml --datadir=/usr/share/sgml/openjade-1.3.2   
make

make install                                                   
make install-man                                               
ln -v -sf openjade /usr/bin/jade                               
ln -v -sf libogrove.so /usr/lib/libgrove.so                    
ln -v -sf libospgrove.so /usr/lib/libspgrove.so                
ln -v -sf libostyle.so /usr/lib/libstyle.so                    

install -v -m644 dsssl/catalog /usr/share/sgml/openjade-1.3.2/ 

install -v -m644 dsssl/*.{dtd,dsl,sgm} /usr/share/sgml/openjade-1.3.2                             

install-catalog --add /etc/sgml/openjade-1.3.2.cat /usr/share/sgml/openjade-1.3.2/catalog                     

install-catalog --add /etc/sgml/sgml-docbook.cat /etc/sgml/openjade-1.3.2.cat

echo "SYSTEM \"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd\" \"/usr/share/xml/docbook/xml-dtd-4.5/docbookx.dtd\"" >> /usr/share/sgml/openjade-1.3.2/catalog


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
