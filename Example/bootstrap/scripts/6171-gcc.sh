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
:
}
unpack()
{
preparepack "$pkgname" "$version" gcc-4.8.2.tar.bz2
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
case `uname -m` in
  i?86) sed -i 's/^T_CFLAGS =$/& -fomit-frame-pointer/' gcc/Makefile.in ;;
esac

sed -i -e /autogen/d -e /check.sh/d fixincludes/Makefile.in 
mv -v libmudflap/testsuite/libmudflap.c++/pass41-frag.cxx{,.disable}

mkdir -pv ../gcc-build
cd ../gcc-build

SED=sed ../gcc-4.8.2/configure --prefix=/usr --enable-shared --enable-threads=posix --enable-__cxa_atexit --enable-clocale=gnu --enable-languages=c,c++ --disable-multilib --disable-bootstrap --with-system-zlib

make

 -s 32768



../gcc-4.8.2/contrib/

make install

ln -sv ../usr/bin/cpp /lib

ln -sv gcc /usr/bin/cc

echo 'main(){}' > .c
cc .c -v -Wl,--verbose &> .log
 -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' .log

grep -B4 '^ /usr/include' .log

grep 'SEARCH.*/usr/lib' .log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " .log

grep found .log

rm -v .c a.out .log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
