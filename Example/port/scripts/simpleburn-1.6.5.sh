#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=simpleburn
version=1.6.5
export MAKEFLAGS='-j 4'
download()
{
nwget http://simpleburn.tuxfamily.org/IMG/bz2/simpleburn-1.6.5.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" simpleburn-1.6.5.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
mkdir -pv build 
cd build 
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DBURNING=LIBBURNIA .. 
make

make install

usermod -a -G cdrom mao


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
