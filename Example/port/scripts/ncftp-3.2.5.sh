#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ncftp
version=3.2.5
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.ncftp.com/ncftp/ncftp-3.2.5-src.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" ncftp-3.2.5-src.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
make -C libncftp shared 
make

make -C libncftp soinstall 
make install

./configure --prefix=/usr --sysconfdir=/etc 
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
