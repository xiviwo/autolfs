#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libgcrypt
version=1.6.1
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnupg.org/gcrypt/libgcrypt/libgcrypt-1.6.1.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libgcrypt-1.6.1.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -dm755   /usr/share/doc/libgcrypt-1.6.1 
install -v -m644    README doc/{README.apichanges,fips*,libgcrypt*} /usr/share/doc/libgcrypt-1.6.1


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
