#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=obex-data-server
version=0.4.6
export MAKEFLAGS='-j 4'
download()
{
nwget http://tadas.dailyda.com/software/obex-data-server-0.4.6.tar.gz
nwget http://www.linuxfromscratch.org/patches/blfs/7.5/obex-data-server-0.4.6-build-fixes-1.patch

}
unpack()
{
preparepack "$pkgname" "$version" obex-data-server-0.4.6.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
patch -Np1 -i ../obex-data-server-0.4.6-build-fixes-1.patch 

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
