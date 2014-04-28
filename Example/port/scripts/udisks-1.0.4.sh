#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=udisks
version=1.0.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://hal.freedesktop.org/releases/udisks-1.0.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" udisks-1.0.4.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var 
make

make profiledir=/etc/bash_completion.d install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
