#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=xvid
version=1.3.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" xvidcore-1.3.2.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
cd build/generic 
./configure --prefix=/usr 
make

sed -i '/libdir.*STATIC_LIB/ s/^/#/' Makefile 
make install 

chmod -v 755 /usr/lib/libxvidcore.so.4.3 
ln -v -sf libxvidcore.so.4.3 /usr/lib/libxvidcore.so.4 
ln -v -sf libxvidcore.so.4   /usr/lib/libxvidcore.so   

install -v -m755 -d /usr/share/doc/xvidcore-1.3.2/examples 
install -v -m644 ../../doc/* /usr/share/doc/xvidcore-1.3.2 
install -v -m644 ../../examples/* /usr/share/doc/xvidcore-1.3.2/examples


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
