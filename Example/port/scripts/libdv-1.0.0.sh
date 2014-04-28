#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=libdv
version=1.0.0
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.sourceforge.net/libdv/libdv-1.0.0.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" libdv-1.0.0.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
./configure --prefix=/usr --disable-xv --disable-static 
make

make install 
install -v -m755 -d      /usr/share/doc/libdv-1.0.0 
install -v -m644 README* /usr/share/doc/libdv-1.0.0


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
