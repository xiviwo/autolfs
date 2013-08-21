#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=coreutils
version=8.21
echo "Building -------------- coreutils-8.21--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf coreutils-8.21.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools --enable-install-program=hostname
make
make install
echo "End of Building -------------- coreutils-8.21--------------"
