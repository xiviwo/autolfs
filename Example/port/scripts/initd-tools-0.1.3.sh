#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=initd-tools
version=0.1.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://people.freedesktop.org/~dbn/initd-tools/releases/initd-tools-0.1.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" initd-tools-0.1.3.tar.gz
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
