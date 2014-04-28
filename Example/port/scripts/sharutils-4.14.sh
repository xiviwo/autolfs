#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sharutils
version=4.14
export MAKEFLAGS='-j 4'
download()
{
nwget ftp://ftp.gnu.org/gnu/sharutils/sharutils-4.14.tar.xz
nwget http://ftp.gnu.org/gnu/sharutils/sharutils-4.14.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" sharutils-4.14.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
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
