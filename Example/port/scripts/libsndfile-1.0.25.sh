#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libsndfile
version=1.0.25
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.mega-nerd.com/libsndfile/files/libsndfile-1.0.25.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libsndfile-1.0.25.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-static 
make

make htmldocdir=/usr/share/doc/libsndfile-1.0.25 install


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
