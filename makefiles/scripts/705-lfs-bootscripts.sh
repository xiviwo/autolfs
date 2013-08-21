#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=lfs-bootscripts
version=20130515
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf lfs-bootscripts-20130515.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make install
