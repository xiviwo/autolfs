#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gnutls
version=3.2.11
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnutls.org/gcrypt/gnutls/v3.2/gnutls-3.2.11.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" gnutls-3.2.11.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --with-default-trust-store-file=/etc/ssl/ca-bundle.crt 
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
