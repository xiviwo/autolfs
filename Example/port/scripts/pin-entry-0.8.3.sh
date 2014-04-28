#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=pin-entry
version=0.8.3
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnupg.org/gcrypt/pinentry/pinentry-0.8.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" pinentry-0.8.3.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
