#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=sg3-utils
version=1.37
export MAKEFLAGS='-j 4'
download()
{
nwget http://sg.danny.cz/sg/p/sg3_utils-1.37.tar.xz

}
unpack()
{
preparepack "$pkgname" "$version" sg3_utils-1.37.tar.xz
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
