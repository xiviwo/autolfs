#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ldns
version=1.6.17
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.nlnetlabs.nl/downloads/ldns/ldns-1.6.17.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" ldns-1.6.17.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --disable-static --with-drill      
make

make install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
