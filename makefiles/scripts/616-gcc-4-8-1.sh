#/bin/bash
set +h
set -e


LFS=/mnt/lfs
SOURCES=$LFS/sources
pkgname=gcc
version=4.8.1
echo "Building -------------- gcc-4.8.1--------------"
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
mkdir -pv ${pkgname}-${version}  
tar xf gcc-4.8.1.tar.bz2 -C ${pkgname}-${version} --strip-components 1
cd ${pkgname}-${version} 
case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac
sed -i 's/install_to_$(INSTALL_DEST) //' libiberty/Makefile.in
sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}
mkdir -v ../gcc-build
cd ../gcc-build
../gcc-4.8.1/configure --prefix=/usr               \
                       --libexecdir=/usr/lib       \
                       --enable-shared             \
                       --enable-threads=posix      \
                       --enable-clocale=gnu        \
                       --enable-languages=c,c++    \
                       --disable-multilib          \
                       --disable-bootstrap         \
                       --disable-install-libiberty \
                       --with-system-zlib
make
make install
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
echo "End of Building -------------- gcc-4.8.1--------------"
