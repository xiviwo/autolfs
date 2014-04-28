#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=rpcbind
version=0.2.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/rpcbind/rpcbind-0.2.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" rpcbind-0.2.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "/servname/s:rpcbind:sunrpc:" src/rpcbind.c 
sed -i "/error = getaddrinfo/s:rpcbind:sunrpc:" src/rpcinfo.c

./configure --prefix=/usr --bindir=/sbin --with-rpcuser=root 
make

make install

mkdir -pv /etc

mkdir -pv ${SOURCES}/blfs-boot-scripts

cd ${SOURCES}/blfs-boot-scripts

tar xf ../blfs-bootscripts-20140301.tar.bz2  --strip-components 1

make install-rpcbind


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
