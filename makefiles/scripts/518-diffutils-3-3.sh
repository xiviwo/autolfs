#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=diffutils
version=3.3
echo "Building -------------- diffutils-3.3--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf diffutils-3.3.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools
make
make install
echo "End of Building -------------- diffutils-3.3--------------"
