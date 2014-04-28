#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lvm2
version=2.02.105
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.105.tgz

}
unpack()
{
preparepack "$pkgname" "$version" LVM2.2.02.105.tgz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --exec-prefix= --with-confdir=/etc --enable-applib --enable-cmdlib --enable-pkgconfig --enable-udev_sync 
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
