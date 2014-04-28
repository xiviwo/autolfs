#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=fdk-aac
version=0.1.3
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/opencore-amr/fdk-aac-0.1.3.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" fdk-aac-0.1.3.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
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
