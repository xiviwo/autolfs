#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=unixodbc
version=2.3.2
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/unixODBC-2.3.2.tar.gz
nwget http://www.unixodbc.org/unixODBC-2.3.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" unixODBC-2.3.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc/unixODBC 
make

make install 

find doc -name "Makefile*" -delete              
chmod 644 doc/{lst,ProgrammerManual/Tutorial}/* 

install -v -m755 -d /usr/share/doc/unixODBC-2.3.2 
cp      -v -R doc/* /usr/share/doc/unixODBC-2.3.2


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
