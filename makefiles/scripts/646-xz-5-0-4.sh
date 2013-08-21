#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=xz
version=5.0.4
echo "Building -------------- xz-5.0.4--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf xz-5.0.4.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/usr --libdir=/lib --docdir=/usr/share/doc/xz-5.0.4
make
make pkgconfigdir=/usr/lib/pkgconfig install
echo "End of Building -------------- xz-5.0.4--------------"
