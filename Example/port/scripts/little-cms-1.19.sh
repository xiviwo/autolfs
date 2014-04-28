#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=little-cms
version=1.19
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/lcms/lcms-1.19.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" lcms-1.19.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make install 
install -v -m755 -d /usr/share/doc/lcms-1.19 
install -v -m644    README.1ST doc/* /usr/share/doc/lcms-1.19


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
