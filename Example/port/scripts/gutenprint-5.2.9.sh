#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gutenprint
version=5.2.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/gimp-print/gutenprint-5.2.9.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gutenprint-5.2.9.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i 's|$(PACKAGE)/doc|doc/$(PACKAGE)-$(VERSION)|' {,doc/,doc/developer/}Makefile.in 
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/gutenprint-5.2.9/api/gutenprint{,ui2} 
install -v -m644    doc/gutenprint/html/* /usr/share/doc/gutenprint-5.2.9/api/gutenprint 
install -v -m644    doc/gutenprintui2/html/* /usr/share/doc/gutenprint-5.2.9/api/gutenprintui2

/etc/rc.d/init.d/cups restart


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
