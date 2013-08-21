#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=m4
version=1.4.16
echo "Building -------------- m4-1.4.16--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf m4-1.4.16.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i -e '/gets is a/d' lib/stdio.in.h
./configure --prefix=/usr
make
sed -i -e '41s/ENOENT/& || errno == EINVAL/' tests/test-readlink.h
make install
echo "End of Building -------------- m4-1.4.16--------------"
