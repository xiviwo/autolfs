#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=strigi
version=0.7.8
export MAKEFLAGS='-j 4'
download()
{
nwget http://www.vandenoever.info/software/strigi/strigi-0.7.8.tar.bz2

}
unpack()
{
preparepack "$pkgname" "$version" strigi-0.7.8.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
sed -i "s/BufferedStream :/STREAMS_EXPORT &/" libstreams/include/strigi/bufferedstream.h 

mkdir -pv build 
cd    build 

cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release -DENABLE_CLUCENE=OFF -DENABLE_CLUCENE_NG=OFF .. 
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
