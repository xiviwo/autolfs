#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=qpdf
version=5.1.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/qpdf/qpdf-5.1.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" qpdf-5.1.1.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/qpdf-5.1.1 
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
