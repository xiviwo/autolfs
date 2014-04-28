#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=parole
version=0.5.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/apps/parole/0.5/parole-0.5.4.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" parole-0.5.4.tar.bz2
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
