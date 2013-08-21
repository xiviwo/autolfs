#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=make
version=3.82
echo "Building -------------- make-3.82--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf make-3.82.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
patch -Np1 -i ../make-3.82-upstream_fixes-3.patch
./configure --prefix=/usr
make
make install
echo "End of Building -------------- make-3.82--------------"
