#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=gcc
version=4.8.2
export MAKEFLAGS='-j 4'
download()
{
nwget http://ftp.gnu.org/gnu/gcc/gcc-4.8.2/gcc-4.8.2.tar.bz2


}
unpack()
{
preparepack "$pkgname" "$version" gcc-4.8.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
make ins-all prefix=/opt/gnat

PATH_HOLD=$PATH 
export PATH=/opt/gnat/bin:$PATH_HOLD

find /opt/gnat -name ld -exec mv -v {} {}.old \;
find /opt/gnat -name as -exec mv -v {} {}.old \;

sed -i 's/\(install.*:\) install-.*recursive/\1/' libffi/Makefile.in         
sed -i 's/\(install-data-am:\).*/\1/'             libffi/include/Makefile.in 

case `uname -m` in
      i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac 

sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}

mkdir -pv ../gcc-build 
cd    ../gcc-build 

../gcc-4.8.2/configure --prefix=/usr --libdir=/usr/lib --enable-shared --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu --disable-multilib --with-system-zlib --enable-lto --enable-languages=c,c++,fortran,ada,go,java,objc,obj-c++ 
make

ulimit -s 32768 
make -k check   

../gcc-4.8.2/contrib/test_summary

make install 

ln -v -sf ../usr/bin/cpp /lib 
ln -v -sf gcc /usr/bin/cc     

mkdir -pv -pv /usr/share/gdb/auto-load/usr/lib              
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib 

chown -v -R root:root /usr/lib/gcc/*linux-gnu/4.8.2/include{,-fixed} /usr/lib/gcc/*linux-gnu/4.8.2/ada{lib,include}

rm -rf /opt/gnat 
export PATH=$PATH_HOLD 
unset PATH_HOLD


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
