#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libpng
version=1.6.9
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libpng/libpng-1.6.9.tar.xz
nwget http://downloads.sourceforge.net/libpng-apng/libpng-1.6.9-apng.patch.gz

}
unpack()
{
preparepack "$pkgname" "$version" libpng-1.6.9.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
gzip -cd ../libpng-1.6.9-apng.patch.gz | patch -p1

./configure --prefix=/usr --disable-static 
make

make install 
mkdir -pv /usr/share/doc/libpng-1.6.9 
cp -v README libpng-manual.txt /usr/share/doc/libpng-1.6.9


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
