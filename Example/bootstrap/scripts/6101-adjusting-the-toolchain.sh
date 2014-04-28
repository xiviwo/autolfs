#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=adjusting-the-toolchain
version=
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
:
}
build()
{
mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(gcc -dumpmachine)/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(gcc -dumpmachine)/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g' -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > `dirname $(gcc --print-libgcc-file-name)`/specs

echo 'main(){}' > .c
cc .c -v -Wl,--verbose &> .log
 -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' .log

grep -B1 '^ /usr/include' .log

grep 'SEARCH.*/usr/lib' .log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " .log

grep found .log

rm -v .c a.out .log

}
download;unpack;build
