#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=aalib
version=1.4rc5
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/aa-project/aalib-1.4rc5.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" aalib-1.4rc5.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4

./configure --prefix=/usr --infodir=/usr/share/info --mandir=/usr/share/man --disable-static          
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
