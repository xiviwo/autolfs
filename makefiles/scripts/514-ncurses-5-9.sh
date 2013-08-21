#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=ncurses
version=5.9
echo "Building -------------- ncurses-5.9--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf ncurses-5.9.tar.gz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/tools --with-shared \
    --without-debug --without-ada --enable-overwrite
make
make install
echo "End of Building -------------- ncurses-5.9--------------"
