#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libesmtp
version=1.0.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.stafford.uklinux.net/libesmtp/libesmtp-1.0.6.tar.bz2
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/libesmtp-1.0.6.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" libesmtp-1.0.6.tar.bz2
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
