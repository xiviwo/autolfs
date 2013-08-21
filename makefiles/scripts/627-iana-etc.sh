#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=iana-etc
version=2.30
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf iana-etc-2.30.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make
make install
