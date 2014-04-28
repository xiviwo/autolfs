#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=hdparm
version=9.43
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/hdparm/hdparm-9.43.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" hdparm-9.43.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make

make install

make binprefix=/usr install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
