#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=lxpolkit
version=0.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lxde/lxpolkit-0.1.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lxpolkit-0.1.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc 
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
