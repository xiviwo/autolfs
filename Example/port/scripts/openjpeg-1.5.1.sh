#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=openjpeg
version=1.5.1
export MAKEFLAGS='-j 4'
download()
{
nwget http://openjpeg.googlecode.com/files/openjpeg-1.5.1.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" openjpeg-1.5.1.tar.gz
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
