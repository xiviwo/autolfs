#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=glibc
version=2.19
export MAKEFLAGS='-j 4'
download()
{
:
}
unpack()
{
preparepack "$pkgname" "$version" glibc-2.19.tar.xz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
if [ ! -r /usr/include/rpc/types.h ]; then
  su -c 'mkdir -pv /usr/include/rpc'
  su -c 'cp -v sunrpc/rpc/*.h /usr/include/rpc'
fi

mkdir -pv ../glibc-build
cd ../glibc-build

../glibc-2.19/configure --prefix=/tools --host=$LFS_TGT --build=$(../glibc-2.19/scripts/config.guess) --disable-profile --enable-kernel=2.6.32 --with-headers=/tools/include libc_cv_forced_unwind=yes libc_cv_ctors_header=yes libc_cv_c_cleanup=yes

make

make install

echo 'main(){}' > .c
$LFS_TGT-gcc .c
 -l a.out | grep ': /tools'

rm -v .c a.out

}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
