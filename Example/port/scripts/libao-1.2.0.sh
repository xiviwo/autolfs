#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libao
version=1.2.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xiph.org/releases/ao/libao-1.2.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libao-1.2.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr 
make

make install 
install -v -m644 README /usr/share/doc/libao-1.2.0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
