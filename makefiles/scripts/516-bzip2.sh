#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=bzip2
version=1.0.6
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf bzip2-1.0.6.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make
make PREFIX=/tools install
