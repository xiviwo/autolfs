#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=gmp
version=5.1.2
echo "Building -------------- gmp-5.1.2--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf gmp-5.1.2.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/usr --enable-cxx
make
make install
mkdir -v /usr/share/doc/gmp-5.1.2
cp    -v doc/{isa_abi_headache,configuration} doc/*.html \
         /usr/share/doc/gmp-5.1.2
echo "End of Building -------------- gmp-5.1.2--------------"
