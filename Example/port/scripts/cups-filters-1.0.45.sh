#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=cups-filters
version=1.0.45
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.openprinting.org/download/cups-filters/cups-filters-1.0.45.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" cups-filters-1.0.45.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --docdir=/usr/share/doc/cups-filters-1.0.45 --without-rcdir --with-gs-path=/usr/bin/gs --with-pdftops-path=/usr/bin/gs --disable-static                            
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
