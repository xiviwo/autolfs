#/bin/bash
set +h
set -e

SOURCES=$LFS/sources
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/functions.sh
pkgname=llvm
version=3.4
export MAKEFLAGS='-j 4'
download()
{
nwget http://llvm.org/releases/3.4/compiler-rt-3.4.src.tar.gz
nwget http://llvm.org/releases/3.4/clang-3.4.src.tar.gz
nwget http://llvm.org/releases/3.4/llvm-3.4.src.tar.gz

}
unpack()
{
preparepack "$pkgname" "$version" llvm-3.4.src.tar.gz
cd ${SOURCES}/${pkgname}-${version} 

}
build()
{
tar -xf ../clang-3.4.src.tar.gz -C tools 
tar -xf ../compiler-rt-3.4.src.tar.gz -C projects 

mv tools/clang-3.4 tools/clang 
mv projects/compiler-rt-3.4 projects/compiler-rt

sed -e 's:\$(PROJ_prefix)/docs/llvm:$(PROJ_prefix)/share/doc/llvm-3.4:' -i Makefile.config.in 
CC=gcc CXX=g++ ./configure --prefix=/usr --sysconfdir=/etc --enable-libffi --enable-optimized --enable-shared --disable-assertions       
make

make install 
for file in /usr/lib/lib{clang,LLVM,LTO}*.a
do
  test -f $file && chmod -v 644 $file
done

install -v -dm755 /usr/lib/clang-analyzer 
for prog in scan-build scan-view
do
  cp -rfv tools/clang/tools/$prog /usr/lib/clang-analyzer/
  ln -sfv ../lib/clang-analyzer/$prog/$prog /usr/bin/
done 
ln -sfv /usr/bin/clang /usr/lib/clang-analyzer/scan-build/ 
mv -v /usr/lib/clang-analyzer/scan-build/scan-build.1 /usr/share/man/man1/


}
clean()
{
cd ${SOURCES}
rm -rf ${pkgname}-${version} 
rm -rf ${pkgname}-build
}
download;unpack;build;clean
