#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=bc
version=1.06.95
echo "Building -------------- bc-1.06.95--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf bc-1.06.95.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/usr --with-readline
make
echo "quit" | ./bc/bc -l Test/checklib.b
make install
echo "End of Building -------------- bc-1.06.95--------------"
