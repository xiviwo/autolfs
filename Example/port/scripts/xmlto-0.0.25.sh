#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xmlto
version=0.0.25
export MAKEFLAGS='-j 4'
download()
{
nwget https://fedorahosted.org/releases/x/m/xmlto/xmlto-0.0.25.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xmlto-0.0.25.tar.bz2
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
