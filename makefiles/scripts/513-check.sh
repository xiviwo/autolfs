#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=check
version=0.9.10
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf check-0.9.10.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools
make
make install
