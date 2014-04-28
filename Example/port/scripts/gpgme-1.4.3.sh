#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gpgme
version=1.4.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnupg.org/gcrypt/gpgme/gpgme-1.4.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" gpgme-1.4.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-fd-passing --disable-gpgsm-test      
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
