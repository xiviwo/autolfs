#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lxtask
version=0.1.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lxde/lxtask-0.1.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lxtask-0.1.4.tar.gz
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
