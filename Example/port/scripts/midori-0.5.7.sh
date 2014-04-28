#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=midori
version=0.5.7
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.midori-browser.org/downloads/midori_0.5.7_all_.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" midori_0.5.7_all_.tar.bz2
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
