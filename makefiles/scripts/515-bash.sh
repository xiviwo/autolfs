#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=bash
version=4.2
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf bash-4.2.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
patch -Np1 -i ../bash-4.2-fixes-12.patch
./configure --prefix=/tools --without-bash-malloc
make
make install
ln -sv bash /tools/bin/sh
