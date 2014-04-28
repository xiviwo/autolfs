#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=joe
version=3.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/joe-editor/joe-3.7.tar.gz
nwget ftp://mirror.ovh.net/gentoo-distfiles/distfiles/joe-3.7.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" joe-3.7.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --sysconfdir=/etc --prefix=/usr 
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
