#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=udev
version=204
echo "Building -------------- udev-204--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf udev-lfs-204-1.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
tar -xvf ../udev-lfs-204-1.tar.bz2
make -f udev-lfs-204-1/Makefile.lfs
make -f udev-lfs-204-1/Makefile.lfs install
build/udevadm hwdb --update
bash udev-lfs-204-1/init-net-rules.sh
echo "End of Building -------------- udev-204--------------"
