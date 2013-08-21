#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=linux
version=3.9.6
echo "Building -------------- linux-3.9.6--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf linux-3.9.6.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
make mrproper
make headers_check
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
echo "End of Building -------------- linux-3.9.6--------------"
