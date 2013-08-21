#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=util-linux
version=2.23.1
echo "Building -------------- util-linux-2.23.1--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf util-linux-2.23.1.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
sed -i -e 's@etc/adjtime@var/lib/hwclock/adjtime@g' \
     $(grep -rl '/etc/adjtime' .)
mkdir -pv /var/lib/hwclock
./configure --disable-su --disable-sulogin --disable-login
make
bash tests/run.sh --srcdir=$PWD --builddir=$PWD
make install
echo "End of Building -------------- util-linux-2.23.1--------------"
