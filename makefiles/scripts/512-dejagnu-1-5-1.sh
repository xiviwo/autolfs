#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=dejagnu
version=1.5.1
echo "Building -------------- dejagnu-1.5.1--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf dejagnu-1.5.1.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools
make install
echo "End of Building -------------- dejagnu-1.5.1--------------"
