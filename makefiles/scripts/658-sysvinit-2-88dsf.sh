#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=sysvinit
version=2.88
echo "Building -------------- sysvinit-2.88--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf sysvinit-2.88dsf.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i 's@Sending processes@& configured via /etc/inittab@g' src/init.c
sed -i -e '/utmpdump/d' \
       -e '/mountpoint/d' src/Makefile
make -C src
make -C src install
echo "End of Building -------------- sysvinit-2.88--------------"
