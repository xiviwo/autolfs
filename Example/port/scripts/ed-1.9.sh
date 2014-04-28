#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=ed
version=1.9
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/pub/gnu/ed/ed-1.9.tar.gz
nwget http://ftp.gnu.org/pub/gnu/ed/ed-1.9.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" ed-1.9.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --bindir=/bin 
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
