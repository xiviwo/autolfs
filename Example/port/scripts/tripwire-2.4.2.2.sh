#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=tripwire
version=2.4.2.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/tripwire/tripwire-2.4.2.2-src.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" tripwire-2.4.2.2-src.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e 's@TWDB="${prefix}@TWDB="/var@' install/install.cfg            
sed -i -e 's/!Equal/!this->Equal/' src/cryptlib/algebra.h                
sed -i -e '/stdtwadmin.h/i#include <unistd.h>' src/twadmin/twadmincl.cpp 
sed -i -e '/TWMAN/ s|${prefix}|/usr/share|' -e '/TWDOCS/s|${prefix}|/usr/share|' install/install.cfg          

./configure --prefix=/usr --sysconfdir=/etc/tripwire                     
make

make install 
cp -v policy/*.txt /usr/share/doc/tripwire

twadmin --create-polfile --site-keyfile /etc/tripwire/site.key /etc/tripwire/twpol.txt 
tripwire --init

tripwire --check > /etc/tripwire/report.txt


twadmin --create-polfile /etc/tripwire/twpol.txt 
tripwire --init


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
