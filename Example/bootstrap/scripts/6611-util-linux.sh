#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=util-linux
version=2.24.1
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" util-linux-2.24.1.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
@etc/adjtime@var/lib/hwclock/adjtime@g' $(grep -rl '/etc/adjtime' .)

mkdir -pv /var/lib/hwclock

./configure

make

 --srcdir=$PWD --builddir=$PWD


-c "PATH=$PATH "

make install

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
