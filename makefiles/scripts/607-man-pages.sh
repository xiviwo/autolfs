#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=man-pages
version=3.51
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf man-pages-3.51.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make install