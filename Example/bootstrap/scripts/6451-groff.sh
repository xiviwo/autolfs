#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=groff
version=1.22.2
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" groff-1.22.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
PAGE=A4 ./configure --prefix=/usr

make

make install

ln -sv eqn /usr/bin/geqn
ln -sv tbl /usr/bin/gtbl

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
