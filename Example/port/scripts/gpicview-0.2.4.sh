#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gpicview
version=0.2.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lxde/gpicview-0.2.4.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" gpicview-0.2.4.tar.gz
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
