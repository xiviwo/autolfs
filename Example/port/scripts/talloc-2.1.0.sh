#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=talloc
version=2.1.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://samba.org/ftp/talloc/talloc-2.1.0.tar.gz
nwget ftp://samba.org/pub/talloc/talloc-2.1.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" talloc-2.1.0.tar.gz
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
