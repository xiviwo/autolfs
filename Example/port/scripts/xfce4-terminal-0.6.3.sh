#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xfce4-terminal
version=0.6.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://archive.xfce.org/src/apps/xfce4-terminal/0.6/xfce4-terminal-0.6.3.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" xfce4-terminal-0.6.3.tar.bz2
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
