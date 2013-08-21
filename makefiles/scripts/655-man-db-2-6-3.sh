#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=man-db
version=2.6.3
echo "Building -------------- man-db-2.6.3--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf man-db-2.6.3.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
./configure --prefix=/usr                        \
            --libexecdir=/usr/lib                \
            --docdir=/usr/share/doc/man-db-2.6.3 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap
make
make install
echo "End of Building -------------- man-db-2.6.3--------------"
