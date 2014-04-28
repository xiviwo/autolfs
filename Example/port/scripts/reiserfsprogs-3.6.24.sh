#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=reiserfsprogs
version=3.6.24
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.kernel.org/pub/linux/kernel/people/jeffm/reiserfsprogs/v3.6.24/reiserfsprogs-3.6.24.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" reiserfsprogs-3.6.24.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sbindir=/sbin 
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
