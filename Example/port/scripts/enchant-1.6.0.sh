#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=enchant
version=1.6.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.abisource.com/downloads/enchant/1.6.0/enchant-1.6.0.tar.gz
nwget ftp://ftp.netbsd.org/pub/pkgsrc/distfiles/enchant-1.6.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" enchant-1.6.0.tar.gz
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
