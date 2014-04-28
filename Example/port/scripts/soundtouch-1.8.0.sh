#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=soundtouch
version=1.8.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.surina.net/soundtouch/soundtouch-1.8.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" soundtouch-1.8.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed "s@AM_CONFIG_HEADER@AC_CONFIG_HEADERS@g" -i configure.ac 
./bootstrap 

./configure --prefix=/usr 
make

make pkgdocdir=/usr/share/doc/soundtouch-1.8.0 install 


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
