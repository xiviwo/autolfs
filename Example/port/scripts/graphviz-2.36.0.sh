#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=graphviz
version=2.36.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://graphviz.org/pub/graphviz/stable/SOURCES/graphviz-2.36.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" graphviz-2.36.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install

ln -v -s /usr/share/graphviz/doc /usr/share/doc/graphviz-2.36.0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
