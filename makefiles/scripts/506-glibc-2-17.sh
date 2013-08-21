#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=glibc
version=2.17
echo "Building -------------- glibc-2.17--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf glibc-2.17.tar.xz -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -p /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi
mkdir -v ../glibc-build
cd ../glibc-build
../glibc-2.17/configure                             \
      --prefix=/tools                               \
      --host=$LFS_TGT                               \
      --build=$(../glibc-2.17/scripts/config.guess) \
      --disable-profile                             \
      --enable-kernel=2.6.25                        \
      --with-headers=/tools/include                 \
      libc_cv_forced_unwind=yes                     \
      libc_cv_ctors_header=yes                      \
      libc_cv_c_cleanup=yes
make
make install
echo "End of Building -------------- glibc-2.17--------------"
