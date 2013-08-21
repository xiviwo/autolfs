#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=tar
version=1.26
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf tar-1.26.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i -e '/gets is a/d' gnu/stdio.in.h
./configure --prefix=/tools
make
make install
