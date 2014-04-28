#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=bind-utilities
version=9.9.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.isc.org/isc/bind9/9.9.5/bind-9.9.5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" bind-9.9.5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make -C lib/dns 
make -C lib/isc 
make -C lib/bind9 
make -C lib/isccfg 
make -C lib/lwres 
make -C bin/dig

make -C bin/dig install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
