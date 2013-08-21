#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=binutils
version=2.23.2
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf binutils-2.23.2.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
rm -fv etc/standards.info
sed -i.bak '/^INFO/s/standards.info //' etc/Makefile.in
sed -i -e 's/@colophon/@@colophon/' \
       -e 's/doc@cygnus.com/doc@@cygnus.com/' bfd/doc/bfd.texinfo
mkdir -v ../binutils-build
cd ../binutils-build
../binutils-2.23.2/configure --prefix=/usr --enable-shared
make tooldir=/usr
make tooldir=/usr install
cp -v ../binutils-2.23.2/include/libiberty.h /usr/include
