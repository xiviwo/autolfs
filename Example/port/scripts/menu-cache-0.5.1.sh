#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=menu-cache
version=0.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lxde/menu-cache-0.5.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" menu-cache-0.5.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
