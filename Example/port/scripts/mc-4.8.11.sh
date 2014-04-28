#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=mc
version=4.8.11
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.osuosl.org/pub/midnightcommander/mc-4.8.11.tar.xz
nwget http://ftp.midnight-commander.org/mc-4.8.11.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" mc-4.8.11.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --enable-charset 
make

make install 
cp -v doc/keybind-migration.txt /usr/share/mc


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
